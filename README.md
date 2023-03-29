# Aplicação Mobile com API Backend de Visão Computacional

Projeto de exemplo usado na disciplina de Sistemas Distribuidos na UFRPE

## Módulos
O sistema é composto de 2 módulos, um app de câmera e um servidor http.


### Câmera
O aplicativo de câmera possui botões principais:
- Extrair texto de uma Foto
- Desenhar Detecçes de uma imagem

E ajustes para configuração de:
- Servidor backend usado
- Focar câmera
- Ativar/Desativar Lanterna


### Servidor
O servidor http possui dois endpoints referentes aos 2 botôes do applicativo:
- Extrair texto
- Desenhar detecçes


> Toda a comunicaço é feita de forma sincrona via requisições http
