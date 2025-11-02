/**
 * @description Data Transfer Object para endereços
 * Value Object da camada de domínio
 * Implementa imutabilidade e validações de negócio
 */
public class AddressDto {
    public final String cep { get; private set; }
    public final String logradouro { get; private set; }
    public final String complemento { get; private set; }
    public final String bairro { get; private set; }
    public final String localidade { get; private set; }
    public final String uf { get; private set; }
    public final String ibge { get; private set; }
    public final String gia { get; private set; }
    public final String ddd { get; private set; }
    public final String siafi { get; private set; }
    
    /**
     * @description Construtor privado para garantir criação via Builder
     */
    private AddressDto(Builder builder) {
        this.cep = builder.cep;
        this.logradouro = builder.logradouro;
        this.complemento = builder.complemento;
        this.bairro = builder.bairro;
        this.localidade = builder.localidade;
        this.uf = builder.uf;
        this.ibge = builder.ibge;
        this.gia = builder.gia;
        this.ddd = builder.ddd;
        this.siafi = builder.siafi;
    }
    
    /**
     * @description Valida se o CEP está em formato válido
     * @param cep CEP para validação
     * @return true se válido
     */
    public static Boolean isValidCep(String cep) {
        if (String.isBlank(cep)) {
            return false;
        }
        
        String cleanCep = cep.replaceAll('[^0-9]', '');
        return cleanCep.length() == 8 && cleanCep.isNumeric();
    }
    
    /**
     * @description Formata CEP para padrão XXXXX-XXX
     * @param cep CEP para formatação
     * @return CEP formatado
     */
    public static String formatCep(String cep) {
        if (!isValidCep(cep)) {
            throw new IllegalArgumentException('CEP inválido: ' + cep);
        }
        
        String cleanCep = cep.replaceAll('[^0-9]', '');
        return cleanCep.substring(0, 5) + '-' + cleanCep.substring(5);
    }
    
    /**
     * @description Builder pattern para criação de AddressDto
     */
    public class Builder {
        private String cep;
        private String logradouro;
        private String complemento;
        private String bairro;
        private String localidade;
        private String uf;
        private String ibge;
        private String gia;
        private String ddd;
        private String siafi;
        
        public Builder setCep(String cep) {
            this.cep = cep;
            return this;
        }
        
        public Builder setLogradouro(String logradouro) {
            this.logradouro = logradouro;
            return this;
        }
        
        public Builder setComplemento(String complemento) {
            this.complemento = complemento;
            return this;
        }
        
        public Builder setBairro(String bairro) {
            this.bairro = bairro;
            return this;
        }
        
        public Builder setLocalidade(String localidade) {
            this.localidade = localidade;
            return this;
        }
        
        public Builder setUf(String uf) {
            this.uf = uf;
            return this;
        }
        
        public Builder setIbge(String ibge) {
            this.ibge = ibge;
            return this;
        }
        
        public Builder setGia(String gia) {
            this.gia = gia;
            return this;
        }
        
        public Builder setDdd(String ddd) {
            this.ddd = ddd;
            return this;
        }
        
        public Builder setSiafi(String siafi) {
            this.siafi = siafi;
            return this;
        }
        
        public AddressDto build() {
            if (!AddressDto.isValidCep(this.cep)) {
                throw new IllegalArgumentException('CEP é obrigatório e deve ser válido');
            }
            
            if (String.isBlank(this.localidade)) {
                throw new IllegalArgumentException('Localidade é obrigatória');
            }
            
            if (String.isBlank(this.uf)) {
                throw new IllegalArgumentException('UF é obrigatória');
            }
            
            return new AddressDto(this);
        }
    }
    
    /**
     * @description Cria novo Builder
     * @return Nova instância do Builder
     */
    public static Builder newBuilder() {
        return new Builder();
    }
}