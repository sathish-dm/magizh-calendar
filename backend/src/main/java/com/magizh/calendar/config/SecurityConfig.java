package com.magizh.calendar.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfigurationSource;

/**
 * Spring Security configuration for API key authentication.
 * - Disables CSRF (stateless API)
 * - Configures public vs protected endpoints
 * - Adds API key authentication filter
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final ApiKeyAuthenticationFilter apiKeyAuthFilter;
    private final CorsConfigurationSource corsConfigurationSource;

    public SecurityConfig(
            ApiKeyAuthenticationFilter apiKeyAuthFilter,
            CorsConfigurationSource corsConfigurationSource) {
        this.apiKeyAuthFilter = apiKeyAuthFilter;
        this.corsConfigurationSource = corsConfigurationSource;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // Enable CORS with our configuration
            .cors(cors -> cors.configurationSource(corsConfigurationSource))

            // Disable CSRF - we're using API keys, not cookies
            .csrf(csrf -> csrf.disable())

            // Stateless sessions - no server-side session storage
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

            // Configure endpoint authorization
            .authorizeHttpRequests(auth -> auth
                // Public endpoints (no auth required)
                .requestMatchers("/api/panchangam/health").permitAll()
                .requestMatchers("/actuator/health", "/actuator/info").permitAll()
                .requestMatchers("/swagger-ui/**", "/swagger-ui.html").permitAll()
                .requestMatchers("/v3/api-docs/**").permitAll()
                .requestMatchers("/error").permitAll()

                // All other API endpoints require authentication
                .requestMatchers("/api/**").authenticated()

                // Allow everything else (static resources, etc.)
                .anyRequest().permitAll()
            )

            // Add our API key filter before Spring's authentication filter
            .addFilterBefore(apiKeyAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
