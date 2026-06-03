import 'dart:io';

void main() async {
  print('============================================');
  print('Agente para enviar repositorio a GitHub');
  print('============================================\n');

  // 1. Preguntar por el link del nuevo repositorio
  stdout.write(
    '1. Introduce el link del nuevo repositorio en GitHub (Ejemplo: https://github.com/usuario/repo.git): ',
  );
  String? repoUrl = stdin.readLineSync();
  if (repoUrl == null || repoUrl.trim().isEmpty) {
    print('Error: El link del repositorio no dartpuede estar vacío.');
    return;
  }
  repoUrl = repoUrl.trim();

  // 2. Preguntar por el mensaje de commit
  stdout.write('2. Introduce el mensaje del commit: ');
  String? commitMessage = stdin.readLineSync();
  if (commitMessage == null || commitMessage.trim().isEmpty) {
    print('Error: El mensaje de commit no puede estar vacío.');
    return;
  }
  commitMessage = commitMessage.trim();

  // 3. Preguntar por el nombre de la rama (por defecto 'main')
  stdout.write(
    '3. Introduce el nombre de la rama (Presiona Enter para usar "main" por defecto): ',
  );
  String? branchName = stdin.readLineSync();
  if (branchName == null || branchName.trim().isEmpty) {
    branchName = 'main';
  } else {
    branchName = branchName.trim();
  }

  print('\nIniciando proceso...\n');

  // Función auxiliar para ejecutar comandos de consola
  Future<bool> runCommand(String executable, List<String> arguments) async {
    print('> $executable ${arguments.join(' ')}');
    var result = await Process.run(executable, arguments, runInShell: true);

    if (result.stdout.toString().isNotEmpty) print(result.stdout);
    if (result.stderr.toString().isNotEmpty) print(result.stderr);

    return result.exitCode == 0;
  }

  // Comprobar si git ya está inicializado, si no, lo inicializamos
  var gitStatus = await Process.run('git', ['status'], runInShell: true);
  if (gitStatus.exitCode != 0) {
    print('Inicializando repositorio git local...');
    bool init = await runCommand('git', ['init']);
    if (!init) {
      print('Error al inicializar git.');
      return;
    }
  }

  // Agrega todos los archivos al staging area
  print('Agregando archivos...');
  bool add = await runCommand('git', ['add', '.']);
  if (!add) {
    print('Error al intentar agregar los archivos.');
    return;
  }

  // Realizar el commit
  print('Creando commit...');
  bool commit = await runCommand('git', ['commit', '-m', commitMessage]);
  if (!commit && gitStatus.exitCode == 0) {
    print(
      'Es posible que no haya cambios para hacer commit. Continuando con el push...',
    );
  }

  // Cambiar a la rama indicada (por ejemplo, main)
  print('Cambiando a la rama $branchName...');
  await runCommand('git', ['branch', '-M', branchName]);

  // Configurar el repositorio remoto
  print('Vinculando con el repositorio remoto...');
  // Primero intentamos remover 'origin' por si ya existía apuntando a otra URL
  await runCommand('git', ['remote', 'remove', 'origin']);
  bool remote = await runCommand('git', ['remote', 'add', 'origin', repoUrl]);
  if (!remote) {
    print('Error al agregar el repositorio remoto.');
    return;
  }

  // Subir los cambios
  print('Subiendo cambios a GitHub...');
  bool push = await runCommand('git', ['push', '-u', 'origin', branchName]);

  if (push) {
    print('\n============================================');
    print('¡Repositorio enviado a GitHub con éxito!');
    print('============================================');
  } else {
    print(
      '\nOcurrió un error al intentar subir los archivos a GitHub. Verifica tus credenciales y el enlace.',
    );
  }
}
