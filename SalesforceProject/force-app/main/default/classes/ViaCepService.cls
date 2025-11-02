/**
 * @description Implementação do serviço ViaCEP
 * Padrão Adapter para integração com API externa
 * Implementa IExternalAddressService
 */
public class ViaCepService implements IExternalAddressService {
    private static final String BASE_URL = 'https://viacep.com.br/ws/';
    private static final String FORMAT = '/json/';
    private static final Integer TIMEOUT = 10000; // 10 segundos
    
    /**
     * @description Busca endereço por CEP na API ViaCEP
     * @param cep CEP para busca
     * @return AddressDto com dados do endereço
     * @throws ExternalServiceException em caso de erro
     */
    public AddressDto getAddressByCep(String cep) {
        if (!AddressDto.isValidCep(cep)) {
            throw new IllegalArgumentException('CEP inválido: ' + cep);
        }
        
        String cleanCep = cep.replaceAll('[^0-9]', '');
        String endpoint = BASE_URL + cleanCep + FORMAT;
        
        try {
            HttpRequest request = buildRequest(endpoint);
            HttpResponse response = executeRequest(request);
            
            return parseResponse(response);
            
        } catch (Exception ex) {
            if (ex instanceof ExternalServiceException) {
                throw ex;
            }
            throw new ExternalServiceException('ViaCEP', 'Erro inesperado: ' + ex.getMessage());
        }
    }
    
    /**
     * @description Verifica se o serviço ViaCEP está disponível
     * @return true se disponível
     */
    public Boolean isServiceAvailable() {
        try {
            HttpRequest request = buildRequest(BASE_URL + '01310-100' + FORMAT);
            HttpResponse response = executeRequest(request);
            return response.getStatusCode() == 200;
        } catch (Exception ex) {
            return false;
        }
    }
    
    /**
     * @description Constrói requisição HTTP
     * @param endpoint URL do endpoint
     * @return HttpRequest configurada
     */
    @TestVisible
    private HttpRequest buildRequest(String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(TIMEOUT);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        return request;
    }
    
    /**
     * @description Executa requisição HTTP
     * @param request Requisição para executar
     * @return HttpResponse da API
     * @throws ExternalServiceException em caso de erro
     */
    @TestVisible
    private HttpResponse executeRequest(HttpRequest request) {
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() != 200) {
            throw new ExternalServiceException(
                'ViaCEP', 
                'Erro na requisição', 
                response.getStatusCode(), 
                response.getBody()
            );
        }
        
        return response;
    }
    
    /**
     * @description Faz parse da resposta JSON para AddressDto
     * @param response Resposta HTTP da API
     * @return AddressDto com dados parseados
     * @throws ExternalServiceException em caso de erro no parse
     */
    @TestVisible
    private AddressDto parseResponse(HttpResponse response) {
        try {
            String responseBody = response.getBody();
            
            if (String.isBlank(responseBody)) {
                throw new ExternalServiceException('ViaCEP', 'Resposta vazia da API');
            }
            
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            
            // ViaCEP retorna {"erro": true} para CEPs não encontrados
            if (jsonData.containsKey('erro') && (Boolean) jsonData.get('erro')) {
                return null; // CEP não encontrado
            }
            
            return AddressDto.newBuilder()
                .setCep((String) jsonData.get('cep'))
                .setLogradouro((String) jsonData.get('logradouro'))
                .setComplemento((String) jsonData.get('complemento'))
                .setBairro((String) jsonData.get('bairro'))
                .setLocalidade((String) jsonData.get('localidade'))
                .setUf((String) jsonData.get('uf'))
                .setIbge((String) jsonData.get('ibge'))
                .setGia((String) jsonData.get('gia'))
                .setDdd((String) jsonData.get('ddd'))
                .setSiafi((String) jsonData.get('siafi'))
                .build();
                
        } catch (JSONException ex) {
            throw new ExternalServiceException('ViaCEP', 'Erro ao fazer parse da resposta JSON: ' + ex.getMessage());
        } catch (Exception ex) {
            throw new ExternalServiceException('ViaCEP', 'Erro ao processar resposta: ' + ex.getMessage());
        }
    }
}