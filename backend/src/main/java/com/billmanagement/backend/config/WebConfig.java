package com.billmanagement.backend.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig
        implements WebMvcConfigurer {

    private final AuthInterceptor authInterceptor;

    public WebConfig(
            AuthInterceptor authInterceptor
    ) {
        this.authInterceptor =
                authInterceptor;
    }

    @Override
    public void addInterceptors(
            InterceptorRegistry registry
    ) {

        registry
                .addInterceptor(
                        authInterceptor
                )

                // =================================================
                // PROTECTED API ROUTES
                // =================================================

                .addPathPatterns(
                        "/api/image/**",
                        "/api/receipt/**",
                        "/api/analysis/**",
                        "/api/account/**"
                )

                // =================================================
                // PUBLIC API ROUTES
                // =================================================

                .excludePathPatterns(
                        "/api/auth/**"
                );
    }
}