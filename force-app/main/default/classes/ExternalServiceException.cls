/**
 * @description Exceção customizada para erros em serviços externos
 * Implementa tratamento específico para falhas de integração
 */
public class ExternalServiceException extends Exception {
    public final String serviceName { get; private set; }
    public final Integer statusCode { get; private set; }
    public final String responseBody { get; private set; }
    
    /**
     * @description Construtor para exceções de serviço externo
     * @param serviceName Nome do serviço que falhou
     * @param message Mensagem de erro
     * @param statusCode Código de status HTTP (opcional)
     * @param responseBody Corpo da resposta (opcional)
     */
    public ExternalServiceException(String serviceName, String message, Integer statusCode, String responseBody) {
        this.serviceName = serviceName;
        this.statusCode = statusCode;
        this.responseBody = responseBody;
        this.setMessage(message);
    }
    
    /**
     * @description Construtor simplificado
     * @param serviceName Nome do serviço que falhou
     * @param message Mensagem de erro
     */
    public ExternalServiceException(String serviceName, String message) {
        this(serviceName, message, null, null);
    }
    
    /**
     * @description Retorna mensagem detalhada do erro
     * @return Mensagem formatada com detalhes do erro
     */
    public override String getMessage() {
        String baseMessage = super.getMessage();
        String details = 'Serviço: ' + serviceName;
        
        if (statusCode != null) {
            details += ', Status: ' + statusCode;
        }
        
        if (String.isNotBlank(responseBody)) {
            details += ', Response: ' + responseBody;
        }
        
        return baseMessage + ' (' + details + ')';
    }
}