
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermosPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entenda!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text('Sobre: 📖',style: TextStyle(fontSize: 20)),
            Text('Dados que coletamos: Esse software armazena dados de matricula e senha para o acesso as funcionalidades da UFSM, e pode armazenar algumas informações adicionais relativo ao seu curso, nome, entre outros.'),
            Text('Armazenamento de dados: Os dados coletados pelo software são armazenados somente no seu dispositivo, e não é coletado por nenhum outro dispositivo externo, seja servidor ou outra entidade.'),
            Text('Estatísticas: Nos damos o direito de coletar dados relativo ao funcionamento do aplicativo, relação de refeições agendadas com refeições não comparecidas, entre outros aspectos, sem comprometer os dados privados do usuário.'),
            Text('Como funciona o aplicativo: O aplicativo gera uma rotina que faz o agendamento diariamente do RU, por isso é necessário que seu celular tenha conexão com a internet.'),
            Text('Configurações do aplicativo: 🛠️',style: TextStyle(fontSize: 20)),
            Text('-Caso queia desativar o agendamento automático, na tela de login clique no botão \'Desativar agendamento automático\''),
            Text('-O agendamento automático se desativa sozinho caso não seja feito o comparecimento a um agendamento feito, fique atento'),
            Text('-O aplicativo vai tentar fazer o agendamento por volta das 2 horas da madrugada para as refeições do dia seguinte, caso não tenha internet ele vai tentar de novo a cada hora, ao passar das 14 horas, o aplicativo vai emitir uma notificação que não conseguiu agendar, e vai parar de tentar agendar para aquele dia'),
            Text('-O aplicativo vai emitir uma notificação avisando que foi agendado para o dia, qual o restaurante, e o tipo da refeição (café, almoço, janta)'),
            Text('-O aplicativo vai emitir uma notificação sempre que não conseguir agendar por motivos de lotação entre outros'),
            Text('-O aplicativo não entra automaticamente na fila do RU.'),
            Text('-O aplicativo pode não funcionar corretamente por conta do desativamento das tarefas em segundo plano.'),
            Text('Desenvolvimento: 💻',style: TextStyle(fontSize: 20)),
            Text('Qualquer interessado em ajudar com o desenvolvimento do aplicativo pode colaborar com o projeto no github.'),
            Text('Aqueles que gostaram e utilizam o aplicativo podem apenas dar uma star⭐ no repositório do github que ajudaria muito! 😀'),
            Text('Contato: 📱',style: TextStyle(fontSize: 20)),
            Text('Email: lh.lagonds@gmail.com ✉️'),
            Text('Insta: @lhlago'),
            InkWell(child: Text('Github: Crazynds',style: TextStyle(color: Colors.blueAccent),),onTap: () =>launch('https://github.com/crazynds/AgendAiUFSM')),

          ],
        ),
      ),
    );
  }

}