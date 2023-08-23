# Teste Cumbuca
Este repositório contém a implementação do case técnico para a vaga de desenvolvedor na Cumbuca.

## Instalação
Siga estas etapas para configurar e executar o projeto em seu ambiente local.

### Pré-requisitos
Antes de começar, certifique-se de ter instalado:

Elixir 1.14.3 https://elixir-lang.org/install.html
Erlang 25 https://www.erlang.org/downloads
PostgreSQL https://www.postgresql.org/download/


### Configuração
Clone este repositório para sua máquina local:

```bash
git clone https://github.com/ThiagoPMaceda/cumbuca-challenge.git
```

Acesse o diretório do projeto:

```bash
cd cumbuca-challenge 
```

Configure o projeto baixando as dependências, configurando o banco de dados e executando as migrations:

```bash
mix setup
```

Inicie o servidor Phoenix:

```bash
mix phx.server
```
Acesse o aplicativo no seu navegador em http://localhost:4000.

## Rotas disponíveis

Essas são as rotas disponíveis dentro do projeto:

### Cadastro de conta
http://localhost:4000/api/v1/sign-in
Cadastra uma conta, o que gera um registro de usuários na tabela `users` e uma nova conta na tabela `accounts`.

#### Dados necessários
```json
{
  "balance": 2459900,
  "user": {
    "name": "Joe",
    "surname": "Doe",
    "cpf": "099.341.822-89",
    "password": "Zt8#ad1"
  }
}
```

Algumas regras desse endpoint:
- O CPF deve ser válido e não pode já estar sendo utilizado por outro usuário; 
- O campo `balance` tem de ser positivo e estou considerando que o usuário irá enviar um inteiro já multiplicado por 100, ou seja, 5.00 reais seria enviado como 500;
- A senha precisa: 
  - Ter pelo menos cinco caracteres;
  - Ter pelo menos uma letra minúscula;
  - Ter pelo menos uma letra maiúscula;
  - Ter de ter um digito ou caractere especial;

### Autenticação
http://localhost:4000/api/v1/login
Autentica um usuário retornando um token que deve ser usado nos demais endpoints.

#### Dados necessários
```json
{
  "cpf": "099.341.822-89",
  "password": "Zt8#ad1"
}
```

### Cadastro de transação
Cadastra uma transação entre dois usuários, com tanto que obedeça as regras de negócio estabelecidas, sendo essa:

- Uma transação só deve ser realizada caso haja saldo suficiente na conta do usuário para realizá-la.

#### Dados necessários
```json
{
  "sender_id": "3999e2d9-9ec4-4bce-b625-904a5b9e4b10",
  "recipient_id": "37a6259e-f612-49e5-bd40-ff7880397978",
  "amount": 500 
}
```

### Estorno de transação
Estorna uma transação, com tanto que obedeça as regras de negócio estabelecidas, sendo essa:

- A transação pode ser estornada apenas uma vez.
- É necessário que a conta que recebeu a transação tenha os fundos necessários para o estorno ocorrer.

#### Dados necessários
```json
{
  "transaction_id": "3999e2d9-9ec4-4bce-b625-904a5b9e4b10"
}
```


### Busca de transações por data
Retorna as transações feitas no intervalo de data informado, o usuário é retornado através do token, essas transações são retornadas em ordem cronológica.


#### Dados necessários
```json
{
  "start_date": "2023-08-01T00:00:00.911400Z",
  "end_date": "2023-08-30T00:00:00.911400Z"
}
```

### Visualização de saldo
Visualiza o saldo do usuário utilizando o token informado.

## Rodando Testes
Para executar os testes automatizados do projeto:

```bash
mix test
```
