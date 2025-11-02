import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchAddressByCep from '@salesforce/apex/AddressController.searchAddressByCep';
import syncAddressFromApi from '@salesforce/apex/AddressController.syncAddressFromApi';
import checkExternalServiceStatus from '@salesforce/apex/AddressController.checkExternalServiceStatus';

/**
 * Lightning Web Component para busca de enderecos
 * 
 * Integra com servicos de endereco via Apex
 * Permite busca local e sincronizacao com API externa
 */
export default class AddressSearch extends LightningElement {
    @track cepValue = '';
    @track addressResult = null;
    @track isLoading = false;
    @track isServiceAvailable = true;
    @track showResult = false;

    /**
     * Classe CSS para status do servico
     */
    get serviceStatusClass() {
        return `service-status ${this.isServiceAvailable ? 'online' : 'offline'}`;
    }

    /**
     * Classe CSS para card de resultado
     */
    get resultCardClass() {
        return `result-card ${this.addressResult ? 'success' : ''}`;
    }

    /**
     * Texto do status do servico
     */
    get serviceStatusText() {
        return this.isServiceAvailable ? 'Servico Online' : 'Servico Offline';
    }

    /**
     * Lifecycle hook - executa quando componente e conectado
     */
    connectedCallback() {
        this.checkServiceStatus();
    }

    /**
     * Handler para mudanca no input de CEP
     * @param {Event} event - Evento de mudanca
     */
    handleCepChange(event) {
        let value = event.target.value;
        
        // Remove caracteres nao numericos
        value = value.replace(/\D/g, '');
        
        // Limita a 8 digitos
        if (value.length > 8) {
            value = value.substring(0, 8);
        }
        
        // Formata o CEP (12345678 -> 12345-678)
        if (value.length > 5) {
            value = value.substring(0, 5) + '-' + value.substring(5);
        }
        
        this.cepValue = value;
        
        // Atualiza o valor no input
        event.target.value = value;
    }

    /**
     * Valida se o CEP tem formato correto
     */
    isValidCep() {
        const cepNumbers = this.cepValue.replace(/\D/g, '');
        return cepNumbers.length === 8;
    }

    /**
     * Handler para busca de endereco
     */
    async handleSearch() {
        if (!this.isValidCep()) {
            this.showToast('Erro', 'Digite um CEP valido com 8 digitos', 'error');
            return;
        }

        this.isLoading = true;
        this.showResult = false;

        try {
            const cepNumbers = this.cepValue.replace(/\D/g, '');
            const result = await searchAddressByCep({ cep: cepNumbers });
            
            if (result) {
                this.addressResult = result;
                this.showResult = true;
                this.showToast('Sucesso', 'Endereco encontrado!', 'success');
            } else {
                this.showToast('Aviso', 'Endereco nao encontrado', 'warning');
            }
        } catch (error) {
            console.error('Erro na busca:', error);
            this.showToast('Erro', 'Erro inesperado na busca de endereco', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * Handler para sincronizacao com API externa
     */
    async handleSync() {
        if (!this.isValidCep()) {
            this.showToast('Erro', 'Digite um CEP valido com 8 digitos', 'error');
            return;
        }

        this.isLoading = true;
        this.showResult = false;

        try {
            const cepNumbers = this.cepValue.replace(/\D/g, '');
            const result = await syncAddressFromApi({ cep: cepNumbers });
            
            if (result) {
                this.addressResult = result;
                this.showResult = true;
                this.showToast('Sucesso', 'Endereco sincronizado com sucesso!', 'success');
            } else {
                this.showToast('Aviso', 'Endereco nao encontrado na API externa', 'warning');
            }
        } catch (error) {
            console.error('Erro na sincronizacao:', error);
            this.showToast('Erro', 'Erro inesperado na sincronizacao', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    /**
     * Handler para limpeza do formulario
     */
    handleClear() {
        this.cepValue = '';
        this.addressResult = null;
        this.showResult = false;
        
        // Limpa o input
        const cepInput = this.template.querySelector('lightning-input');
        if (cepInput) {
            cepInput.value = '';
        }
    }

    /**
     * Verifica status do servico externo
     */
    async checkServiceStatus() {
        try {
            this.isServiceAvailable = await checkExternalServiceStatus();
        } catch (error) {
            console.error('Erro ao verificar status do servico:', error);
            this.isServiceAvailable = false;
        }
    }

    /**
     * Exibe toast de notificacao
     * @param {string} title - Titulo da mensagem
     * @param {string} message - Conteudo da mensagem
     * @param {string} variant - Tipo da mensagem (success, error, warning, info)
     */
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}