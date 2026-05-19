# 🌀 Maze App - Guia de Configuração Rápida

Este projeto consiste numa aplicação Android que comunica com um backend PHP/MySQL para monitorizar uma simulação de labirinto (PISID 25/26).

## 🛠️ 1. Configurar a Base de Dados
1.  Abre o teu gestor de MySQL (phpMyAdmin ou MySQL Workbench).
2.  Executa o script SQL fornecido para criar a base de dados `simulacao_labirinto` e as tabelas.
3.  Cria um utilizador de teste para fazeres login:
    ```sql
    INSERT INTO Utilizador (Nome, Email, Password, Tipo) 
    VALUES ('Utilizador Teste', 'root@gmail.com', 'root', 'ADM');
    ```

## 🌐 2. Correr o Backend (PHP)
O Android precisa de aceder ao servidor através da rede local.
1.  Abre o terminal na pasta `maze_app_php`.
2.  Executa o comando:
    ```bash
    php -S 0.0.0.0:8001
    ```
    *Nota: O `0.0.0.0` permite que dispositivos externos (telemóvel ou emulador) se liguem ao teu PC.*

## 📱 3. Configurar e Usar a App
1.  Abre o projeto no **Android Studio**.
2.  Garante que o teu telemóvel está na **mesma rede Wi-Fi** que o teu PC.
3.  No ecrã de Login da App:
    *   **Host:** Coloca o IP do teu PC seguido da porta (Ex: `192.168.1.14:8001`).
    *   **Username:** `root@gmail.com`
    *   **Password:** `root`
    *   **Database:** `simulacao_labirinto`
4.  Clica em **Connect** para entrar.

## ⚠️ Dicas de Resolução de Problemas
*   **Firewall:** Se o telemóvel não ligar, a Firewall do Windows pode estar a bloquear a porta 8001. Verifica as permissões ou desativa-a temporariamente.
*   **IP do PC:** Podes encontrar o teu IP escrevendo `ipconfig` no terminal (procura por IPv4).
*   **Tabelas Vazias:** Se as abas da App estiverem vazias, certifica-te de que existem dados nas tabelas `Mensagem`, `Temperatura`, `Som` e `OcupacaoLabirinto`.
