package com.example.first.controller;


import java.util.Random;
import java.math.BigDecimal;
import java.math.RoundingMode;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RestController;

import com.example.first.model.RequestDTO;
import com.example.first.model.ResponseDTO;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;



@RestController
public class MainController {

    private Logger log = LoggerFactory.getLogger(getClass());

    ObjectMapper mapper = new ObjectMapper();

    @PostMapping(
        value = "/info/postBalances",
        produces = MediaType.APPLICATION_JSON_VALUE,
        consumes = MediaType.APPLICATION_JSON_VALUE
    )
    public Object postBalances(@RequestBody RequestDTO requestDTO)
    throws JsonProcessingException {

        log.debug(
            "********** RequestDTO **********\n"
            + mapper.writerWithDefaultPrettyPrinter()
            .writeValueAsString(requestDTO)
        );

        BigDecimal maxLimit, balance;
        String currency;
        try {

            String clientId = requestDTO.getClientId();
            char firstDigit = clientId.charAt(0);
            if (firstDigit == '9') {
                maxLimit = new BigDecimal("1000.00");
                currency = new String("EU");
            } else if (firstDigit == '8') {
                maxLimit = new BigDecimal("2000.00");
                currency = new String("US");
            } else {
                maxLimit = new BigDecimal("10000.00");
                currency = new String("RUB");
            }

            Random random = new Random();
            balance = new BigDecimal(random.nextDouble())
                .multiply(maxLimit)
                .setScale(2, RoundingMode.HALF_UP);

            ResponseDTO responseDTO = new ResponseDTO(
                requestDTO.getRqUID(),
                clientId,
                requestDTO.getAccount(),
                currency,
                balance,
                maxLimit
            );

            log.debug(
                "********** ResponseDTO **********\n"
                + mapper.writerWithDefaultPrettyPrinter()
                .writeValueAsString(responseDTO)
            );

            return responseDTO;

        }
        catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(e.getMessage());
        }
    }
}
