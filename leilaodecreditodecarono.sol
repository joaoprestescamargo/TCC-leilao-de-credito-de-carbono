// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.10;


contract LeilaoDeCreditoDeCarbono {

    struct Ofertante {
        string nome;
        address payable enderecoCarteira;
        uint oferta;
        bool jaFoiReembolsado;
    }
    
    string public leiDoContrato;
    
    uint public cotacaoAtualDoCreditoDeCarbonoEmEther;
    
    // O Incremento Mínimo será de 1 Ether
    uint public incrementoMinimo;
    
    // A comissão do leiloeiro será calculada em porcentagem (%)
    uint public comissaoDoLeiloeiro;

    address payable public contaBovespa;
    uint public prazoFinalLeilao;

    address public maiorOfertante;
    uint public maiorLance;

    mapping(address => Ofertante) public listaOfertantes;
    Ofertante[] public ofertantes;

    bool public encerrado;

    event novoMaiorLance(address ofertante, uint valor);
    event fimDoLeilao(address arrematante, uint valor);

    modifier somenteBovespa {
        require(msg.sender == contaBovespa, "Somente Bovespa pode realizar essa operacao");
        _;
    }

    constructor(
        uint _duracaoLeilao,
        address payable _contaBovespa,
        uint quantidadeEmToneladasDoLote,
        string memory leiBrasileira
        
    ) public {
        contaBovespa = _contaBovespa;
        prazoFinalLeilao = now + _duracaoLeilao;
        quantidadeEmToneladasDoLote = 500;
        leiDoContrato = leiBrasileira;
        cotacaoAtualDoCreditoDeCarbonoEmEther = 16;
        incrementoMinimo = 1;
        comissaoDoLeiloeiro =5;
    }


    function lance(string memory nomeOfertante, address payable enderecoCarteiraOfertante) public payable {
        require(now <= prazoFinalLeilao, "Leilao encerrado");
        require(msg.value > maiorLance, "Já foram apresentados lances maiores");
        
        maiorOfertante = msg.sender;
        maiorLance = msg.value;

        
        for (uint i=0; i<ofertantes.length; i++) {
            Ofertante storage ofertantePerdedor = ofertantes[i];
            if (!ofertantePerdedor.jaFoiReembolsado) {
                ofertantePerdedor.enderecoCarteira.transfer(ofertantePerdedor.oferta);
                ofertantePerdedor.jaFoiReembolsado = true;
    }
    }
        
        Ofertante memory ofertanteVencedorTemporario = Ofertante(nomeOfertante, enderecoCarteiraOfertante, msg.value, false);
        
        ofertantes.push(ofertanteVencedorTemporario);
        
        listaOfertantes[ofertanteVencedorTemporario.enderecoCarteira] = ofertanteVencedorTemporario;
    
        emit novoMaiorLance (msg.sender, msg.value);
    }
    
    // Acesso ao Edital do Leilão BOVESPA
    function store(string memory editalLeilaoBovespa) public {
    }
    
    function comissionamento () public view returns (uint) {
         return comissaoDoLeiloeiro;
    }

    function finalizaLeilao() public somenteBovespa {
       
        require(now >= prazoFinalLeilao, "Leilao ainda nao encerrado.");
        require(!encerrado, "Leilao encerrado.");

        encerrado = true;
        emit fimDoLeilao(maiorOfertante, maiorLance);

        contaBovespa.transfer(address(this).balance);
    }
}
