package com.example.first;


import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.springframework.http.MediaType;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;

import com.example.first.model.RequestDTO;
import com.example.first.model.ResponseDTO;
import com.fasterxml.jackson.databind.ObjectMapper;

@SpringBootTest
@AutoConfigureMockMvc
class FirstApplicationTests {

    @Autowired
    private MockMvc mockMvc;
    @Autowired
    private ObjectMapper objectMapper;
    private RequestDTO requestDTO = new RequestDTO(
        "58dgtf565j8547f64ke7",
        null,
        "90500000000000000001",
        "2020-01-01",
        "2025-01-01"
    );

    @Test
    void testPostBalances_Success_EU()
    throws Exception {
        requestDTO.setClientId("9050000000000000000");
        // Выполнение запроса и проверка ответа
        mockMvc.perform(post("/info/postBalances")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(requestDTO)))
            .andDo(print()) // Печать ответа для отладки
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.currency").value("EU"))
            .andExpect(jsonPath("$.maxLimit").value("1000.00"))
            .andExpect(result -> {
                ResponseDTO responseDTO = objectMapper.readValue(
                    result.getResponse().getContentAsString(),
                    ResponseDTO.class
                );
                // Проверка, что баланс меньше лимита
                assertTrue(
                    responseDTO.getBalance()
                    .compareTo(responseDTO.getMaxLimit()) <= 0,
                    "Balance must not exceed the maxLimit"
                );
            });
    }

    @Test
    void testPostBalances_Success_US()
    throws Exception {
        requestDTO.setClientId("8050000000000000000");
        // Выполнение запроса и проверка ответа
        mockMvc.perform(post("/info/postBalances")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(requestDTO)))
            .andDo(print()) // Печать ответа для отладки
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.currency").value("US"))
            .andExpect(jsonPath("$.maxLimit").value("2000.00"))
            .andExpect(result -> {
                ResponseDTO responseDTO = objectMapper.readValue(
                    result.getResponse().getContentAsString(),
                    ResponseDTO.class
                );
                // Проверка, что баланс меньше лимита
                assertTrue(
                    responseDTO.getBalance()
                    .compareTo(responseDTO.getMaxLimit()) <= 0,
                    "Balance must not exceed the maxLimit"
                );
            });
    }

    @Test
    void testPostBalances_Success_RUB()
    throws Exception {
        requestDTO.setClientId("*050000000000000000");
        // Выполнение запроса и проверка ответа
        mockMvc.perform(post("/info/postBalances")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(requestDTO)))
            .andDo(print()) // Печать ответа для отладки
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.currency").value("RUB"))
            .andExpect(jsonPath("$.maxLimit").value("10000.00"))
            .andExpect(result -> {
                ResponseDTO responseDTO = objectMapper.readValue(
                    result.getResponse().getContentAsString(),
                    ResponseDTO.class
                );
                // Проверка, что баланс меньше лимита
                assertTrue(
                    responseDTO.getBalance()
                    .compareTo(responseDTO.getMaxLimit()) <= 0,
                    "Balance must not exceed the maxLimit"
                );
            });
    }

    @Test
    void testPostBalances_BAD_REQUEST()
    throws Exception {
        // Выполнение запроса и проверка ответа
        mockMvc.perform(post("/info/postBalances")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(requestDTO)))
            .andDo(print()) // Печать ответа для отладки
            .andExpect(status().isBadRequest());
    }
}
