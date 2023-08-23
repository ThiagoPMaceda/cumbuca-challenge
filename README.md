# Teste Cumbuca
Este repositório contain a implementação do case técnico para a vaga de desenvolvedor na Cumbuca.

## Instalação
Siga estas etapas para configurar e executar o projeto em seu ambiente local.

### Pré-requisitos
Antes de começar, certifique-se de ter instalado:

Elixir 1.14.3 https://elixir-lang.org/install.html
Erlang 25 https://www.erlang.org/downloads
PostgreSQL https://www.postgresql.org/download/


### Configuração
Clone este repositório para sua máquina local:

```
bash
Copy code
git clone https://github.com/ThiagoPMaceda/cumbuca-challenge.git
```

Acesse o diretório do projeto:

```
bash
cd cumbuca-challenge 
Instale as dependências do Elixir:
```

Configure o projeto baixando as dependências, configurando o banco de dados e executando as migrations:

```
bash
mix setup
```

Inicie o servidor Phoenix:

```
bash
mix phx.server
```
Acesse o aplicativo no seu navegador em http://localhost:4000.


## Rodando Testes
Para executar os testes automatizados do projeto:

```
bash
mix test
```
