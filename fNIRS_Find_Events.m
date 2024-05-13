%% ROTINA DESENVOLVIDA PARA ENCONTRAR OS EVENTOS NO fNIRS
% Desenvolvedor: Gabriel Antonio Gazziero Moraca
% Abril de 2024

%% Instruções ao usuário
clear; clc
instructions = char({'Antes de rodar esta rotina, execute as tarefas descritas abaixo:';' ';...
    '1) Abra o arquivo ".txt", que foi exportado do Oxysoft, e copie/cole os dados em um arquivo Excel.';...
    '2) No arquivo Excel, exclua o cabeçalho, bem como as primeiras linhas dos dados do NIRS (valores altos).';...
    '3) Exclua a coluna do tempo/frames (1ª coluna) e a do Portasync, se existir (coluna de zeros - O).';...
    '4) Na coluna de eventos (coluna 17), adicione a letra "a" na primeira linha.';...
    '5) Verifique se todos os eventos (letras) aparecem na coluna e se estão na sequência realizada durante a coleta.';...
    '6) Salve o arquivo em ".xlsx".';' ';'- Se em algum arquivo a letra "a" não aparecer, você precisará arrumar o arquivo Excel.';...
    '- A rotina irá salvar os eventos de cada condição em um único arquivo ".mat".';...
    '- Considere o baseline como uma condição experimental, caso exista evento(s) para este período.';...
    '- Além disso, os dados numéricos do Excel (Oxy e Desoxy) serão salvos em um novo arquivo ".txt".';...
    '- Ambos os arquivos serão utilizados no processamento dos dados no NIRS-SPM.';' ';'Pressione ENTER para iniciar a análise.';}); % "char" converte a célula em uma matriz de caracteres
disp(instructions)
pause
clc

%% Adicionando informações sobre o protocolo experimental do usuário

% Definindo a quantidade de condições experimentais e de eventos
questions_protocol = {'Digite a quantidade de condições experimentais:' 'Digite a quantidade de eventos marcados:'};
protocol = str2double(inputdlg(questions_protocol,'Informações sobre protocolo',[1,70])); % "inputdlg" cria uma caixa de diálogo; "str2double" transforma uma string em número

% Verificando se o usuário preencheu com núemros os campos da caixa de diálogo do protocolo
if any(isnan(protocol)) % "isnan" verifica se algum elemento da matriz numérica é NaN (not a number); "any" retorna verdadeiro se pelo menos 1 elemento for NaN
    error('É mandatório definir a quantidade de condições experimentais e de eventos marcados. Reinicie a análise.'); % "error" interrompe a rotina com uma mensagem de erro
end

% Selecionando a quantidade de condições e tentativas
number_conditions = protocol(1);
number_tents = protocol(2);

% Inicializando uma célula vazia para armazenar as instruções da caixa de diálogo dos eventos
questions_letras = cell(1,number_conditions); 

% Criando as instruções da caixa de diálogo dos eventos
for e = 1:number_conditions
    prompt = sprintf('Digite a letra referente aos eventos da %dª condição:',e); % "sprintf" formata uma string com texto e numeros
    questions_letras{e} = prompt; % Armazenando as instruções em cada elemento da célula
end

% Definindo as letras dos eventos
letras_eventos = strtrim(inputdlg(questions_letras,'Eventos a serem analisados',[1,70])); % "strtrim" retira espaços antes e depois da string
letras_eventos = upper(letras_eventos); % "upper" deixa a string em maiúscula

% Verificando se o usuário definiu as letras dos eventos
if any(cellfun('isempty',letras_eventos)) % "cellfun" aplica "isempty" (é vazia) em cada elemento da célula; % "any" retorna verdadeiro se pelo menos 1 elemento estiver vazio
    error('É mandatório definir as letras dos eventos de cada condição experimental. Reinicie a análise.');
end

% Definindo como os dados exportados estão organizados
options = {'Em uma única pasta' 'Em subpastas para cada participante'};
question_path_analise = {'Como os arquivos Excel estão organizados?';' ';'Selecione uma das opções abaixo:'};
dir = listdlg('PromptString',question_path_analise,'ListString',options,'SelectionMode','single','Name','Dados exportados',...
    'ListSize',[250 100]); % "listdlg" cria uma caixa de diálogo com uma lista de opções para serem selecionadas e retorna os índices dessa lista

% Definindo onde os dados analisados serão salvos
question_path_save = {'Onde você quer salvar os eventos?';' ';'Selecione uma das opções abaixo:'};
dir_save = listdlg('PromptString',question_path_save,'ListString',options,'SelectionMode','single','Name','Dados analisados','ListSize',[250 100]);

% Criando as instruções da caixa de diálogo dos diretórios
if dir == 1 && dir_save == 1
    questions_dir = {'Digite o diretório que contém os arquivos Excel:' 'Digite o diretório onde os eventos serão salvos:'};
elseif dir == 2 && dir_save == 1
    questions_dir = {'Os arquivos Excel estão em subpastas para cada participante. Digite o diretório que contém as subpastas:'...
        'Digite o diretório onde os eventos serão salvos:'};
elseif dir == 1 && dir_save == 2
    questions_dir = {'Digite o diretório que contém os arquivos Excel:'...
        'Os eventos serão salvos em subpastas para cada participante. Digite o diretório que contém as subpastas:'};
elseif dir == 2 && dir_save == 2
    questions_dir = {'Os arquivos Excel estão em subpastas para cada participante. Digite o diretório que contém as subpastas:'...
        'Os eventos serão salvos em subpastas para cada participante. Digite o diretório que contém as subpastas:'};
end

% Definindo diretórios que contém os arquivos e para salvar os dados
paths = strtrim(inputdlg(questions_dir,'Definindo os diretórios',[1,70]));

% Verificando se o usuário preencheu os campos com diretórios existentes
if any(~cellfun(@isfolder,paths)) % "cellfun" aplica "isfolder" (é um diretório) em cada elemento da célula; "~" nega o resultado da função (ou seja, se um elemento for um diretório, ela retorna falso); 
    % "any" retorna verdadeiro se pelo menos 1 elemento não for um diretório
    error('É mandatório definir diretórios existentes. Reinicie a análise.');
end

% Selecionando os diretórios
path_analise_initial = paths{1};
path_save_initial = paths{2};

clearvars questions_protocol protocol questions_letras e prompt options question_path_save questions_dir paths

%% Analisando os dados exportados e selecionando os eventos de interesse

% Criando uma expressão regular para encontrar os eventos
padrao_evento = '[A-Za-z]\d+'; % Contém uma letra e um número

% Criando uma função anônima para verificar se uma célula contém um evento
verificar_evento = @(x) ~isempty(regexp(x,padrao_evento,'once')); % "regexp" verifica se há uma única correspondência da expressão regular na string "x"; "~isempty" retorna verdadeiro 
%"~isempty" (não é diferente de vazio) retorna verdadeiro se o resultado de "regexp" for vazio

continua = 'Sim'; % Servirá para manter ou encerrar o loop "while"
while continua == "Sim"

    % Se há subpastas para cada participante (seja para organizar os arquivos Excel ou os eventos que serão salvos)
    if dir == 2 || dir_save == 2 % || = ou
        participante = strtrim(input('Digite o código do participante (nome da pasta) que será analisado: ','s')); % "input" solicita entrada do usuário
        disp(' ')
    end
    
    % Definindo o diretório onde os arquivos Excel estão organizados
    if dir == 2
        path_analise = [path_analise_initial,'\',participante]; % Se os dados foram organizados em subpastas para cada participante
    else
        path_analise = path_analise_initial;
    end

    % Definindo o diretório onde os dados serão salvos
    if dir_save == 2
        path_save = [path_save_initial,'\',participante]; % Se o usuário escolheu salvar os dados em subpastas para cada participante
    else
        path_save = path_save_initial;
    end

    % Abrindo o diretório que contém os arquivos
    cd(path_analise)
   
    % Selecionando os arquivos com os eventos (em .xlsx)
    [arquivos,path_analise] = uigetfile('.xlsx','multiselect','on','Selecione os arquivos para análise'); % "uigetfile" cria uma janela de diálogo para selecionar arquivos que possuem a extensão especificada

    for narq = 1:length(arquivos)
        S = warning('OFF');

        % Abrindo arquivo de interesse
        filename = arquivos{narq};
        [data, txt, everything] = xlsread(filename); % "xlsread" serve para ler arquivos Excel
    
        % Criando o nome do arquivo analisado
        [~, n_colunas] = size(filename); % Como "filename" é uma string, "n_linhas" será 1 e "n_colunas" será a o nº de caracteres
        name_arq = filename(1,1:n_colunas-5); % -5 para excluir o ".xlsx"

        % Selecionando a coluna dos eventos
        col_eventos = txt(:,1); % É uma matriz de células (cada elemento é uma célula)
    
        % Removendo possíveis espaços em branco das células de "col_eventos"
        col_eventos_filtered = strtrim(col_eventos);
    
        % Verificando se "a" está na 1º linha do arquivo    
        linha1 = ' - 1ª linha do excel: ';

        if strcmpi(col_eventos_filtered{1},'a') % "strcmpi" verfifica se duas strings são iguais (sem diferenciar maiúsculas de minúsculas)
            a = col_eventos_filtered{1};
        else
            error('A letra "a" não está na primeira linha do excel. Arrume o arquivo e reinicie a análise.');
        end
        
        letra_conf = [name_arq linha1 a];
        disp(char({letra_conf;' '}))

        clearvars filename txt everything n_colunas col_eventos linha1 a letra_conf

        % Aplicando a função anônima em cada célula de "col_eventos_filtered"
        all_eventos = find(cellfun(verificar_evento,col_eventos_filtered)); % "cellfun" aplica a função "verificar_evento" em cada célula e retorna um vetor com 0 e/ou 1
        % "find" retorna as linhas contendo 1 (linhas que contém os eventos)

        % Obtendo todas as marcações (letras) utilizadas na coleta 
        all_marcacoes = col_eventos_filtered(all_eventos);

        % Selecionando as marcações dos eventos de interesse
        indices_eventos_selecionados = listdlg('PromptString','Selecione os eventos de interesse:','ListString',all_marcacoes,...
            'SelectionMode','multiple','Name',['Eventos do ' name_arq],'ListSize',[300 250]);
        eventos_selecionados = all_eventos(indices_eventos_selecionados); % Retorna as linhas dos eventos selecionados
        marcacoes_selecionadas = all_marcacoes(indices_eventos_selecionados); % Retorna as letras dos eventos selecionados

        % Verificando se o usuário selecionou mais eventos do que o número de tentativas do protocolo
        if numel(eventos_selecionados) > number_tents % "numel" retorna o número de elementos da matriz
            error('Número de eventos selecionados (%d) excede o número de eventos realizados na coleta (%d). Reinicie a análise.',numel(eventos_selecionados),number_tents);
        end

        % Inicializando uma célula vazia para armazenar os eventos de cada condição
        data_eventos = cell(1,number_conditions);

        % Definindo os eventos de cada condição
        disp('Analisando:')

        for i = 1:number_conditions
            letra = letras_eventos{i};
            disp(['- Eventos ',letra])
            indices = find(contains(marcacoes_selecionadas,letra)); % "contains" verifica se "letra" está em "marcacoes_selecionadas" e retorna um vetor com 0 e/ou 1
            % "find" retorna as linhas contendo 1 (linhas que contém a "letra")
            eventos = eventos_selecionados(indices)/10; % Divide por 10 para os eventos funcionarem no NIRS-SPM           

            % Armazenando os eventos de cada condição em um elemento da célula
            data_eventos{i} = eventos'; % ' Para os eventos da condição "i" ficarem dispostos em colunas
        end
        
        %% Salvando os eventos e os dados numéricos (Oxy e Desoxy)
        
        % Abrindo o diretório onde os dados serão salvos
        cd(path_save)
        disp(char({' ';'Salvando os dados...'}))
        pause(1)

        % Inicializando uma estrutura de dados vazia para armazenar todos os eventos
        fNIRS_Eventos = struct();

        % Preenchendo a estrutura com todos eventos de cada condição
        for z = 1:number_conditions
            letra = letras_eventos{z};
            campo = ['Evento_', letra]; % Criando um campo para a condição "z"
            fNIRS_Eventos.(campo) = data_eventos{z}; % Armazenando os eventos da condição "z'
        end

        % Criando o nome do arquivo e salvando a estrutura em formato ".mat"
        name_arq_res = [name_arq,'_fNIRS_Eventos'];
        save(name_arq_res,'fNIRS_Eventos');
    
        % Salvando os dados numéricos em formato .txt
        dados_numericos = data(:,1:16);
        save([name_arq,'_FINAL.txt'], 'dados_numericos','-ascii','-tabs');
    
        % Retornando ao diretório que contém os arquivos
        % Necessário para a rotina encontrar o próximo arquivo a ser analisado
        disp(char({' ';'Próximo arquivo...';' '}))
        cd(path_analise)    
    end

    continua = questdlg('Você quer encontrar eventos de mais arquivos?','Término da análise','Sim','Não','Sim');
    % "questdlg" cria uma caixa de diálogo com uma pergunta e botões de resposta
    clc
end

cd(path_save)
clear; clc
disp(char({'Os eventos da fNIRS foram encontrados.';'OBRIGADO PELA COLABORAÇÃO!'}))