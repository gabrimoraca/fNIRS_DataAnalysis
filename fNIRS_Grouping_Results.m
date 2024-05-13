%% ROTINA DESENVOLVIDA PARA AGRUPAR OS DADOS DA fNIRS
% Desenvolvedor: Gabriel Antonio Gazziero Moraca
% Abril de 2024

%% Instru��es ao usu�rio
clear; clc
instructions = char({'Para a rotina funcionar corretamente, se atente aos pontos abaixo:';' ';...
    '1) Os dados da fNIRS devem ter sido analisados por meio da rotina "fNIRS_Analysis.m".';...
    '2) Todos os dados, previamente analisados, devem estar em uma �nica pasta, independente do n�mero de grupos.';...
    '3) A rotina agrupar� os dados de acordo com as condi��es e janelamento de interesse, salvando-os em arquivos Excel.';...
    '4) � essencial saber a quantidade e os nomes das condi��es experimentais, momentos de avalia��o e interven��es aplicadas.';...
    '5) Nunca digite n�meros por extenso (um, dois...) quando for solicitada a entrada de valores.';...
    '6) Use abrevia��es para nomear as condi��es experimentais (AR - andar r�pido; TD - tarefa dupla, etc).';...
    '7) Se n�o houve interven��o no estudo, deixe em o branco o campo que nomeia a interven��o.';...
    '8) Se houve somente 1 momento de avalia��o, deixe em o branco o campo que nomeia o momento.';' ';'Pressione ENTER para iniciar a an�lise.';}); % "char" converte a c�lula em uma matriz de caracteres
disp(instructions)
pause
clc

%% Adicionando informa��es sobre o protocolo experimental do usu�rio

% Definindo a quantidade de condi��es experimentais, momentos e interven��es
questions_protocol_numbers = {'Digite o n�mero de condi��es experimentais:' 'Digite o n�mero de momentos de avalia��o:'...
    'Digite o n�mero de interven��es. Se n�o houve interven��es, digite 1:'};
protocol = str2double(inputdlg(questions_protocol_numbers,'Informa��es sobre o protocolo',[1,75])); % "inputdlg" cria uma caixa de di�logo; "str2double" transforma uma string em n�mero

% Verificando se o usu�rio preencheu todos os campos da caixa de di�logo do protocolo com n�meros
if any(isnan(protocol)) % "isnan" verifica se algum elemento da matriz num�rica � NaN (not a number); "any" retorna verdadeiro se pelo menos 1 elemento for NaN
    error('� mandat�rio definir a quantidade de condi��es experimentais, momento e interven��es. Reinicie a an�lise.'); % "error" interrompe a rotina com uma mensagem de erro
end

% Selecionando as quantidades de condi��es, momentos e interven��es
n_conds = protocol(1);
n_momentos = protocol(2);
n_interventions = protocol(3);

% Inicializando c�lulas vazias para armazenar as instru��es da caixa de di�logo
questions_conds = cell(1,n_conds); 
questions_momentos = cell(1,n_momentos);
questions_interventions = cell(1,n_interventions);

% Criando as instru��es da caixa de di�logo do protocolo
for i = 1:n_conds
    prompt = sprintf('Digite o nome da condi��o %d:',i); % "sprintf" formata uma string com texto e numeros
    questions_conds{i} = prompt; % Armazenando cada instru��o em um elemento da c�lula
end

for i = 1:n_momentos
    prompt = sprintf('Digite o nome do momento %d:',i);
    questions_momentos{i} = prompt;
end

for i = 1:n_interventions
    prompt = sprintf('Digite o nome da interven��o %d:',i);
    questions_interventions{i} = prompt;
end

% Definindo os nomes das condi��es, momentos e interven��es
questions_protocol_names = [questions_conds questions_momentos questions_interventions];
all_names = strtrim(inputdlg(questions_protocol_names,'Informa��es sobre o protocolo',[1,70])); % "strtrim" retira espa�os antes e depois da string

% Selecionando os nomes de todas as condi��es, momentos e interven��es
names_conds = all_names(1:n_conds);
names_momentos = all_names(1 + n_conds:end - n_interventions);
names_interventions = all_names(1 + n_conds + n_momentos:end);

% Definindo os diret�rios 
questions_paths = {'Digite o diret�rio que cont�m os dados analisados:' 'Digite o diret�rio onde os resultados agrupados ser�o salvos:'};
all_paths = strtrim(inputdlg(questions_paths,'Definindo os diret�rios',[1,70]));

% Verificando se o usu�rio preencheu todos os campos com diret�rios existentes
if any(~cellfun(@isfolder,all_paths)) % "cellfun" aplica "isfolder" (� um diret�rio) em cada elemento da c�lula; "~" nega o resultado da fun��o (ou seja, se um elemento for um diret�rio, ela retorna falso); 
    % "any" retorna verdadeiro se pelo menos 1 elemento n�o for um diret�rio
    error('� mandat�rio definir diret�rios existentes. Reinicie a an�lise.');
end

% Selecionando os diret�rios
path_analise = all_paths{1};
path_save = all_paths{2};

clearvars questions_protocol_numbers protocol questions_conds questions_momentos questions_interventions questions_protocol_names...
    prompt all_names questions_paths all_paths

%% Selecionando os arquivos que cont�m os dados analisados da fNIRS

% Abrindo o diret�rio que cont�m os arquivos
cd(path_analise)

% Listando os arquivos contidos no diret�rio
list_arq = dir('*.mat'); % "dir" retorna informa��es (nome, local, data...) sobre os arquivos que possuem a extens�o especificada

% Selecionando os nomes dos arquivos
names_arq = {list_arq.name}'; % ' Transp�e os dados para uma coluna (estavam em uma linha)

% Inicializando uma matriz de c�lulas vazias para armazenar os nomes dos arquivos
arquivos_cond = cell(n_interventions*n_momentos,1); % Em cada c�lula haver� os nomes dos arquivos de um conjunto interven��o-momento
contador = 1; % Servir� de �ndice para armazenar corretamente os nomes dos arquivos em "arquivos_cond"

% Selecionando os arquivos de interesse conforme cada interven��o-momento
for w = 1:n_interventions
    intervention = names_interventions{w};

    for x = 1:n_momentos
        momento = names_momentos{x};

        % Criando a instru��o da caixa de di�logo
        if isempty(intervention) || isempty(momento) % "isempty" verifica se a vari�vel est� vazia; || = OU
            instrucao = {'Selecione os arquivos de interesse:'};
        else
            instrucao = {'Selecione os arquivos das condi��es abaixo:';['- Interven��o: ' intervention];['- Momento: ' momento]};
        end

        % Selecionando os arquivos (�ndices dos arquivos)
        indices_arq = listdlg('PromptString',instrucao,'ListString',names_arq,'SelectionMode','multiple','Name','Dados analisados',...
            'ListSize',[300,280]); % "listdlg" cria uma caixa de di�logo com uma lista de op��es para serem selecionadas e retorna os �ndices dessa lista

        % Armazenando cada bloco de arquivos em uma c�lula da matriz
        arquivos_cond{contador} = names_arq(indices_arq); % Cada elemento de "arquivos_cond" � uma c�lula

        % Atualizando o contador para o pr�ximo loop            
        contador = contador + 1;
    end
end

% Verificando se nenhuma c�lula de "arquivs_cond" est� vazia
if any(cellfun('isempty',arquivos_cond)) % "cellfun" aplica "isempty" em cada elemento da c�lula; "any" retorna verdadeiro se pelo menos 1 elemento estiver vazio
    error('O usu�rio n�o selecionou todos os arquivos de interesse. Reinicie a an�lise')
end

% Definindo as legendas das vari�veis de acordo com a aplica��o ou n�o da ETCC
if any(contains(names_arq,'HE')) || any(contains(names_arq,'HD')) % "contains" verifica se h� "HD" ou "HE" nos nomes dos arquivos
    measures = {'Oxy_S_' 'Des_S_' 'Oxy_NS_' 'Des_NS_' 'Oxy_Both_' 'Des_Both_'}; % "any" retorna verdadeiro se houver "HD" ou "HE" em pelo menos 1 nome
else
    measures = {'Oxy_Left_' 'Des_Left_' 'Oxy_Right_' 'Des_Right_' 'Oxy_Both_' 'Des_Both_'};
end

clearvars list_arq names_arq instrucao indices_arq

%% Selecionando os dados da fNIRS de cada arquivo

% Agrupando horizontalmente os arquivos de cada combina��o
all_arquivos = vertcat(arquivos_cond{:}); % "vertcat" concatena verticalmente os dados das c�lulas (nomes dos arquivos)

% Definindo o janelamento dos dados a ser agrupados
janelamento = questdlg('Voc� quer agrupar os dados de qual janelamento?',...
    'Definindo o janelamento','Total','Early','Late','Total'); % "questdlg" cria uma caixa de di�logo com uma pergunta e bot�es de resposta

% Inicializando uma c�lula vazia para armazenar os canais utilizados
channels = cell(numel(all_arquivos),1); % "numel" retorna o n�mero de elementos da c�lula

% Inicializando uma c�lula vazia para armazenar os c�digos dos participantes
all_codigos = cell(numel(all_arquivos),1);

% Inicializando uma matriz de c�lulas vazias para armazenar os dados de todos os arquivos e condi��es
all_data = cell(numel(all_arquivos),n_conds);

disp('Agrupando os dados da fNIRS dos seguintes arquivos:')

for narq = 1:length(all_arquivos)
    S = warning('OFF');

    % Abrindo o arquivo de interesse
    filename = all_arquivos{narq};
    load(filename);
    
    % Criando o nome do arquivo analisado
    underline_find = max(strfind(filename,'_')); % "strfind" retorna um vetor com as posi��es dos "_" em "filename"; "max" retorna a �ltima ocorr�ncia de "_" (�ltima posi��o)
    name_arq = filename(1,1:underline_find-1); % "name_arq" ser� do 1� caractere de "filename" at� o caractere antes do �ltimo "_"
    disp(['- ' name_arq])

    % Armazenando os c�digos de cada participante
    all_codigos{narq} = name_arq;

    % Selecionando os canais analisados
    ch = num2str(fNIRS_Results.Channels); % "num2str" transforma n�meros em strings
    channels{narq} = ch; % Armazenando os canais de cada arquivo na c�lula

    % Selecionando os dados do janelamento escolhido
    tabela_dados = table2array(fNIRS_Results.(janelamento)); % "table2array" transforma uma tabela em matriz (exclui as legendas)

    % Inicializando uma c�lula vazia para armazenar os dados de cada condi��o experimental do arquivo "narq"
    data_conds = cell(1,n_conds); 

    % Definindo �ndices para acessar os dados de cada condi��o experimental
    primeira_coluna = 1; 
    ultima_coluna = 6; % Cada condi��o possui 6 colunas no arquivo

    % Selecionando os dados de acordo com a quantidade de condi��es
    for i = 1:n_conds
        data = tabela_dados(:,primeira_coluna:ultima_coluna);

        % Distinguindo os dados em hemisf�rio esquerdo/direito ou estimulado/n�o estimulado
        if contains(filename,'HE','IgnoreCase',true) % Se houve ETCC no hemisf�rio esquerdo
            data_s = data(:,[1 3]); % "s" = estimulado
            data_ns = data(:,[2 4]); % "ns" = n�o estimulado
            data_oxy_des = [data_s data_ns];            
        elseif contains(filename,'HD','IgnoreCase',true) % Se houve ETCC no hemisf�rio direito
            data_s = data(:,[2 4]);
            data_ns = data(:,[1 3]);
            data_oxy_des = [data_s data_ns];
        else % Se n�o houve ETCC em um dos hemisf�rios
            data_left = data(:,[1 3]);
            data_right = data(:,[2 4]);
            data_oxy_des = [data_left data_right]; % Oxy-Left; Des-Left; Oxy-Right; Des-Right
        end

        % Selecionando os dados combinados (m�dias) entre os hemisf�rios        
        data_oxy_des_both_H = data(:,[5 6]);

        % Armazenando os dados de cada condi��o em um elemento da c�lula
        data_conds{i} = [data_oxy_des data_oxy_des_both_H]; 

        % Atualizando os indices para selecionar os dados da pr�xima condi��o
        primeira_coluna = primeira_coluna + 6;
        ultima_coluna = ultima_coluna + 6;
    end

    % Armazenando os dados de cada arquivo em uma c�lula da matriz
    for i = 1:n_conds
        all_data(narq,i) = data_conds(:,i); % Cada elemento de "all_data" � uma c�lula
    end
end

clearvars narq filename underline_find name_arq ch tabela_dados primeira_coluna ultima_coluna...
    data data_s data_ns data_left data_right data_oxy_des data_oxy_des_both_H data_conds

%% Combinando os nomes das condi��es experimentais e interven��es

% Inicializando uma c�lula vazia para armazenar as combina��es
conditions = cell(n_conds*n_interventions,1);
contador = 1; % Servir� de �ndice para armazenar corretamente as combina��es

for x = 1:n_conds
    condicao = names_conds{x};

    for y = 1:n_interventions
        intervention = names_interventions{y};

            % Armazenando cada combina��o em um elemento da c�lula
            if isempty(intervention) % Se n�o houver interven��o, utiliza somente a condi��o experimental
                conditions{contador} = condicao;
            else
                conditions{contador} = [condicao '_' intervention];
            end

            % Atualizando o contador para o pr�ximo loop
            contador = contador + 1;
    end
end

%% Agrupando todos os dados de acordo com cada condi��o-interven��o-momento

% Inicializando uma matriz de c�lulas vazias para armazenar os c�digos dos participantes (nomes dos arquivos fNIRS analisados)
res_codigos = cell(numel(conditions),1);

% Inicializando uma matriz de c�lulas vazias para armazenar os dados de cada condi��o-interven��o-momento
res_data = cell(numel(conditions)*n_momentos,1);

% Descobrindo a quantidade de arquivos em cada c�lula de "arquivos_cond"
indices_arq = cellfun(@numel,arquivos_cond); % "cellfun" aplica a fun��o "numel" em cada c�lula da matriz de c�lulas "arquivos_cond"

% Criando um vetor com a soma cumulativa dos elementos de "indices_arq"
indices_arq_acumulados = cumsum(indices_arq); % "cumsum" calcula a soma cumulativa dos elementos
contador = 1; % Servir� de �ndice para armazenar corretamente os dados e os c�digos

for x = 1:n_conds
    first_line = 1;
    
    for y = 1:numel(indices_arq_acumulados)
        last_line = indices_arq_acumulados(y); % Linha que cont�m os dados do �ltimo arquivo do bloco interven��o-momento 
    
        if y > 1
            first_line = first_line + indices_arq(y-1);
        end

        % Armazenando os dados de cada condi��o-interven��o-momento em uma c�lula da matriz
        res_data{contador} = all_data(first_line:last_line,x); % Cada coluna de "all_data" cont�m os dados de uma condi��o

        % Armazenando os c�digos de cada condi��o-interven��o-momento em uma c�lula da matriz
        res_codigos{contador} = all_codigos(first_line:last_line);

        % Atualizando o contador para o pr�ximo loop
        contador = contador + 1;
    end    
end

% Organizando as matrizes "res" para separar os dados de cada momento em colunas distintas  
if n_momentos > 1

    res_data_temporario = {}; % Criando c�lulas vazias
    res_codigos_temporario = {};

    % Separando os dados e os c�digos por momentos
    for i = 1:n_momentos
        res_data_temporario(:,i) = res_data(i:n_momentos:end);
        res_codigos_temporario(:,i) = res_codigos(i:n_momentos:end);
    end

    % Rearmazenando nas matrizes de c�lulas originais
    res_data = res_data_temporario;
    res_codigos = res_codigos_temporario;
end

clearvars -EXCEPT path_save all_arquivos janelamento channels measures n_momentos names_momentos conditions res_data res_codigos

%% Salvando os dados de cada condi��o e os canais utilizados

% Abrindo o diret�rio onde os dados ser�o salvos
cd(path_save)

% Salvando os canais analisados em formato ".txt"
res_channels = [all_arquivos channels];
writecell(res_channels,'fNIRS_Canais_Analisados','Delimiter','\t') % "writecell" salva dados de c�lulas em arquivo .txt

% Inicializando uma matriz de c�lulas vazias para armazenar os nomes das vari�veis
res_outcomes = cell(numel(conditions),n_momentos); 

% Criando os nomes das vari�veis
for w = 1:numel(conditions)
    cond = conditions{w};

    for x = 1:n_momentos
        momento = names_momentos{x};

        % Armazenando as legendas nas c�lulas
        if isempty(momento) % Se houver somente 1 momento de avalia��o
            res_outcomes{w,x} = {'Codigo' [measures{1} cond] [measures{2} cond] [measures{3} cond] [measures{4} cond] [measures{5} cond] [measures{6} cond]};
        else
            res_outcomes{w,x} = {'Codigo' [measures{1} cond '_' momento] [measures{2} cond '_' momento] [measures{3} cond '_' momento]...
                [measures{4} cond '_' momento] [measures{5} cond '_' momento] [measures{6} cond '_' momento]};
        end
    end
end

% Salvando os dados em arquivos Excel
disp(char({' ';'Salvando os dados agrupados...'}))
pause(1)

for x = 1:numel(conditions)
    name_arq_excel = ['fNIRS_' janelamento '_' conditions{x} '_.xlsx'];

    for z = 1:n_momentos % Cada aba da planilha ir� conter os dados de um momento
        plan = names_momentos{z};
        outcomes = res_outcomes{x,z};
        ordem = res_codigos{x,z};
        dados = cell2mat(res_data{x,z}); % "cell2mat" transforma uma c�lula em matriz

        xlswrite(name_arq_excel,outcomes,plan,'A1') % "xlswrite" cria arquivo Excel
        xlswrite(name_arq_excel,ordem,plan,'A2')
        xlswrite(name_arq_excel,dados,plan,'B2')
    end
end

clear; clc
disp(char({'Acabou!! Os resultados da fNIRS foram agrupados.';'OBRIGADO PELA COLABORA��O!'}))