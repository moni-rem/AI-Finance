package com.finora.ai;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping
public class ChatController {
    private static final int REQUESTS_PER_MINUTE = 20;
    private final Map<String, Deque<Instant>> requestsByUserId = new ConcurrentHashMap<>();
    private final GeminiChatService gemini;

    public ChatController(GeminiChatService gemini) {
        this.gemini = gemini;
    }

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of("ok", true, "provider", "gemini");
    }

    @PostMapping("/chat")
    public ChatResponse chat(
            @Valid @RequestBody ChatRequest request,
            @RequestHeader(value = "Authorization", required = false) String authorization) {
        FirebaseToken token = verifyFirebaseToken(authorization);
        enforceRateLimit(token.getUid());
        return new ChatResponse(gemini.reply(request));
    }

    private FirebaseToken verifyFirebaseToken(String authorization) {
        if (authorization == null || !authorization.startsWith("Bearer ")) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED, "Sign in to use the AI assistant.");
        }
        String idToken = authorization.substring("Bearer ".length()).trim();
        if (idToken.isEmpty()) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED, "Sign in to use the AI assistant.");
        }
        try {
            return FirebaseAuth.getInstance().verifyIdToken(idToken);
        } catch (FirebaseAuthException error) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED, "Your sign-in has expired. Please sign in again.");
        }
    }

    private void enforceRateLimit(String userId) {
        Instant cutoff = Instant.now().minusSeconds(60);
        Deque<Instant> recent = requestsByUserId.computeIfAbsent(
                userId, ignored -> new ArrayDeque<>());
        synchronized (recent) {
            while (!recent.isEmpty() && recent.peekFirst().isBefore(cutoff)) {
                recent.removeFirst();
            }
            if (recent.size() >= REQUESTS_PER_MINUTE) {
                throw new ResponseStatusException(
                        HttpStatus.TOO_MANY_REQUESTS,
                        "Too many requests. Please wait a minute and try again.");
            }
            recent.addLast(Instant.now());
        }
    }

    public record ChatRequest(
            @NotBlank @Size(max = 4000) String message,
            @Size(max = 12) java.util.List<ChatMessage> history,
            @com.fasterxml.jackson.annotation.JsonProperty("financial_context")
                    com.fasterxml.jackson.databind.JsonNode financialContext) {}

    public record ChatMessage(
            @NotBlank @Size(max = 4000) String role,
            @NotBlank @Size(max = 4000) String content) {}

    public record ChatResponse(String answer) {}
}
