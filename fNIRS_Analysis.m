%% ROTINA DESENVOLVIDA PARA AN�LISE DOS DADOS DA fNIRS
% Desenvolvedor: Gabriel Antonio Gazziero Moraca
% Abril de 2024

%% Instru��es ao usu�rio
clear; clc
disp('Antes de come�ar a an�lise, se atende aos itens abaixo:')
disp(' ')
disp('- Os eventos de interesse devem ter sido encontrados por meio da rotina "fNIRS_Find_Eventos.m".')
disp('- Os dados devem ter sido processados e filtrados CORRETAMENTE no NIRS-SPM.')
disp('- Os arquivos "fNIRSplots_Channels.m" e "fNIRSplots_ConditionsData.m" s�o fun��es que servem para plotar os dados.')
disp('- Esta rotina e as fun��es que plotam os dados DEVEM estar no mesmo diret�rio. ')
disp('- Os dados ser�o analisados em 3 janelamentos: "Early", "Late" e "Total".')
disp('- Ser�o criadas figuras para cada condi��o experimental, crie diret�rios para salv�-las.')
disp('- Nunca digite n�meros por extenso (um, dois...) quando for solicitada a entrada de valores.')
disp('- Use abrevia��es para nomear as condi��es experimentais (AR - andar r�pido; TD - tarefa dupla, etc).')
disp('- Por fim, voc� deve saber, previamente:')
disp('1) Os canais 1-4 s�o do hemisf�rio direito e os canais 5-8 s�o do hesmif�rio esquerdo.')
disp('2) A quantidade de condi��es experimentais.')
disp('3) Os eventos de cada condi��o e do baseline (se houver).')
disp('4) A dura��o total dos per�odos baseline e tarefa.')
disp('5) A dura��o da tarefa em cada janelamento.')
disp('6) Quanto tempo do baseline e da tarefa ser�o exclu�dos e analisados.');
disp('7) Qual foi o hemisf�rio estimulado em cada participante, se houve aplica��o da ETCC em apenas um hemisf�rio.')
disp(' ')
disp('Pressione ENTER para iniciar a an�lise.')
pause
clc

%% Adicionando informa��es sobre o protocolo experimental do usu�rio

% Definindo a frequ�ncia de coleta em Hz
freq = 10;

% Definindo a quantidade de condi��es experimentais e o diret�rio que cont�m as rotinas
options = {'Digite a quantidade de condi��es experimentais:' 'Digite o diret�rio que cont�m as rotinas para an�lise da fNIRS:'};
protocol1 = strtrim(inputdlg(options,'Informa��es sobre o protocolo',[1 70])); % "inputdlg" cria uma caixa de di�logo; "strtrim" retira espa�os antes e depois da string

% Selecionando a quantidade de condi��es
number_conditions = str2double(protocol1{1}); % "str2double" transforma uma string em n�mero

% Adicionando o diret�rio que cont�m as rotinas para analisar os dados
path_scripts = addpath(protocol1{2}); % "addpath" adiciona um diret�rio na rotina

% Verificando se o usu�rio definiu a quantidade de condi��es
if ~isnumeric(number_conditions) % "~isnumeric" verifica se a vari�vel n�o � um n�mero
    error('� mandat�rio definir a quantidade de condi��es experimentais. Reinicie a an�lise.'); % "error" interrompe a rotina com uma mensagem de erro
end

% Inicializando c�lulas vazias para armazenar as instru��es da caixa de di�logo do protocolo
questions_protocol = cell(2,number_conditions);

% Criando as instru��es da caixa de di�logo do protocolo
for i = 1:number_conditions
    prompt1 = sprintf('Digite o nome da %d� condi��o:',i); % "sprintf" formata uma string com texto e numeros
    prompt2 = sprintf('Digite a letra dos eventos da %d� condi��o:',i);

    % Armazenando cada instru��o em um elemento da c�lula
    questions_protocol{1,i} = prompt1;
    questions_protocol{2,i} = prompt2;
end

% Definindo o nome das condi��es e a letras dos eventos
protocol2 = strtrim(inputdlg(questions_protocol,'Informa��es sobre o protocolo',[1 70]));

% Verificando se o usu�rio preencheu todos os campos da caixa de di�logo do protocolo
if any(cellfun('isempty',protocol2)) % "cellfun" aplica a fun��o "isempty" (� vazia) em cada elemento da c�lula; % "any" retorna verdadeiro se pelo menos 1 elemento estiver vazio
    error('� mandat�rio nomear todas as condi��es experimentais e letras dos eventos. Reinicie a an�lise.');
end

% Selecionando os nomes das condi��es e as letras
name_cond = protocol2(1:2:end);
letras_eventos = upper(protocol2(2:2:end)); % "upper" transforma a string em mai�scula

% Definindo como os eventos est�o organizados
options = {'Em uma �nica pasta' 'Em subpastas para cada participante'};
questions_eventos = {'Como os arquivos dos eventos est�o organizados?';' ';'Selecione uma das op��es abaixo:'};
dir_evento = listdlg('PromptString',questions_eventos,'ListString',options,'SelectionMode','single',...
    'Name','Eventos da fNIRS','ListSize',[250 100]); % "listdlg" cria uma caixa de di�logo com uma lista de op��es para serem selecionadas e retorna os �ndices dessa lista

% Definindo se houve aplica��o da ETCC
etcc_pergunta = questdlg('Houve estimula��o em um hemisf�rio cerebral espec�fico?','Aplica��o da ETCC','Sim','N�o','Sim'); % "questdlg" cria uma caixa de di�logo com uma pergunta e bot�es de resposta

% Inicializando c�lula vazia para armazenar algumas instru��es da caixa de di�logo dos diret�rios
questions_figures = cell(1,number_conditions);

% Criando as instru��es da caixa de di�logo dos diret�rios
if dir_evento == 1
    questions_eventos = {'Digite o diret�rio que cont�m os eventos dos participantes:'};
else
    questions_eventos = {'Os eventos foram salvos em subpastas para cada participante. Digite o diret�rio que cont�m as subpastas:'};
end

for i = 1:number_conditions
    cond = name_cond{i};
    prompt = sprintf('Digite o diret�rio para salvar os gr�ficos da condi��o %s:',cond);
    questions_figures{i} = prompt;
end

questions_channels_data = {'Digite o diret�rio onde os gr�ficos dos canais ser�o salvos:' 'Digite o diret�rio que cont�m os dados filtrados no SPM:'...
    'Digite o diret�rio onde os dados analisados ser�o salvos:'};
questions_paths = [questions_eventos questions_figures questions_channels_data];

% Definindo os diret�rios
paths = strtrim(inputdlg(questions_paths,'Definindo os diret�rios',[1 67]));

% Verificando se o usu�rio preencheu os campos com diret�rios existentes
if any(~cellfun(@isfolder,paths)) % "cellfun" aplica "isfolder" (� um diret�rio) em cada elemento da c�lula; "~" nega o resultado da fun��o (ou seja, se um elemento for um diret�rio, ela retorna falso); 
    % "any" retorna verdadeiro se pelo menos 1 elemento n�o for um diret�rio
    error('� mandat�rio definir diret�rios existentes. Reinicie a an�lise.');
end

% Selecionando os diret�rios
path_evento = paths{1};
addpath(path_evento) % Adicionando o diret�rio que cont�m os eventos (ou as subpastas dos participantes)
paths_figures = paths(2:1:end-3); % -3 porque os �ltimos 3 elementos ser�o diret�rios referentes aos canais e dados e n�o as condi��es
path_channels = paths{end-2};
path_analise = paths{end-1};
path_save = paths{end};

clearvars questions_protocol protocol1 protocol2 prompt1 prompt2 options questions_eventos prompt questions_figures questions_channels_data questions_paths paths cond

%% Adicionando informa��es para analisar os dados da fNIRS

% Definindo se existe um evento baseline e a letra deste evento
baseline_pergunta = questdlg('H� um evento baseline no seu protocolo?',' ','Sim','N�o','N�o'); 

if baseline_pergunta == "Sim"    
    letra_evento_baseline = strtrim(upper(input('Digite a letra que identifica o baseline: ','s'))); % "input" solicita entrada do usu�rio
end

% Criando as instru��es da caixa de di�logo do baseline
questions_baseline = {'Digite a dura��o TOTAL realizado na coleta, em segundos:' 'Digite quantos segundos, imediatamente ANTES do IN�CIO da tarefa, ser�o exclu�dos:'};

% Definindo a dura��o do baseline durante a coleta e o quanto ser� analisado
measures_baseline = str2double(inputdlg(questions_baseline,'Informa��es sobre o BASELINE',[1 70]));

% Verificando se o usu�rio preencheu todos os campos da caixa de di�logo do baseline com n�meros
if any(isnan(measures_baseline)) % "isnan" verifica se algum elemento da matriz num�rica � NaN (not a number); "any" retorna verdadeiro se pelo menos 1 elemento for NaN
    error('� mandat�rio preencher todos os campos referentes ao Baseline. Reinicie a an�lise.');
end

% Selecionando as medidas do baseline
baseline = measures_baseline(1)*freq; % multiplica por "freq" para passar pra frames
baseline_correction = measures_baseline(2)*freq;

% Criando as instru��es da caixa de di�logo da tarefa
questions_tarefa = {'Digite a dura��o do atraso fisiol�gico, em segundos:' 'Digite o tempo TOTAL realizado na coleta, em segundos:'...
    'Digite quantos segundos, ANTES do T�RMINO da tarefa, ser�o exclu�dos. Se n�o for excluir, digite 0:'...
    'Digite a dura��o dos janelamentos "Early" e "Late", em segundos:'};

% Definindo dura��es da tarefa, atraso fisiol�gico e janelamentos
measures_tarefa = str2double(inputdlg(questions_tarefa,'Informa��es sobre a TAREFA',[1 70]));

% Verificando se o usu�rio preencheu todos os campos da caixa de di�logo da tarefa com n�meros
if any(isnan(measures_tarefa))
    error('� mandat�rio preencher todos os campos referentes ao Baseline. Reinicie a an�lise.');
end

% Selecionando as medidas da tarefa
atraso_fisiologico = measures_tarefa(1)*freq;
task_raw = measures_tarefa(2)*freq;
task_correction = measures_tarefa(3)*freq;
task_janelada = measures_tarefa(4)*freq;
frame_start_task = baseline + atraso_fisiologico; % Representa o in�cio da tarefa, desconsiderando o atraso fisiol�gico
frame_start_task_late = frame_start_task + task_janelada; % Representa o in�cio da tarefa no janelamento late

% Definindo os nomes dos janelamentos que ser�o analisados
janelamentos = {'Early' 'Late' 'Total'};

% Inicializando c�lulas vazias para armazenar as legendas das vari�veis
parameters_raw = cell(numel(janelamentos),number_conditions); % "numel" retorna o n�mero de elementos da c�lula
parameters_means_stds = cell(1,number_conditions);

% Definindo as legendas das tabelas que ser�o salvas
for y = 1:number_conditions
    cond = name_cond{y};

    for z = 1:numel(janelamentos)
        janela = janelamentos{z};

        % Armazenando cada legenda em um elemento da c�lula
        parameters_raw{z,y} = {['Left_Oxy_' janela '_' cond] ['Right_Oxy_' janela '_' cond] ['Left_Des_' janela '_' cond]...
            ['Right_Des_' janela '_' cond] ['Both_Oxy_' janela '_' cond] ['Both_Des_' janela '_' cond]};
    end

    % Armazenando cada legenda em um elemento da c�lula
    parameters_means_stds{y} = {['Left_Oxy_' cond] ['Right_Oxy_' cond] ['Left_Des_' cond] ['Right_Des_' cond] ['Both_Oxy_' cond] ['Both_Des_' cond]};
end

% Definindo as legendas dos canais
list_right_channels = {'Canal 1' 'Canal 2' 'Canal 3' 'Canal 4'};
list_left_channels = {'Canal 5' 'Canal 6' 'Canal 7' 'Canal 8'};

clc
clearvars baseline_pergunta questions_baseline measures_baseline questions_tarefa measures_tarefa cond janela

%% Analisando os dados pr�-processados da fNIRS

% Abrindo o diret�rio que cont�m os arquivos
cd(path_analise)

% Selecionando os arquivos de interesse (.mat)
[arquivos,path_analise] = uigetfile('.mat','multiselect','on','Selecione os arquivos para an�lise'); % "uigetfile" cria uma janela de di�logo para selecionar arquivos que possuem a extens�o especificada

for narq = 1:length(arquivos)
    S = warning('OFF');

    % Carregando o arquivo de interesse
    filename = arquivos{narq};
    load(filename);

    % Criando o nome do participante
    underline_find = strfind(filename,'_'); % "strfind" retorna um vetor com as posi��es dos "_" em "filename"
    underline_find_max = max(underline_find); % "max" retorna o maior �ndice de "underline_find", que � a �ltima ocorr�ncia de "_"
    underline_find_min = min(underline_find); % "min" retorna o menor �ndice de "underline_find", que � a primeira ocorr�ncia de "_"
    name_arq = filename(1,1:underline_find_max-1); % "name_arq" ser� do 1� caractere de "filename" at� o caractere antes do �ltimo "_"
    codigo = filename(1,1:underline_find_min-1); % "c�digo" ser� do 1� caractere at� o caractere antes do 1� "_"
    disp(name_arq)

    % Identificando o hemisf�rio estimulado, se houve aplica��o da ETCC em um dos hemisf�rios
    if etcc_pergunta == "Sim"        
        H_estimulado = questdlg(['Qual hemisf�rio foi estimulado no ' name_arq '?'],'Aplica��o da ETCC','Esquerdo','Direito','Direito');
        
        if H_estimulado == "Direito"
            H_estimulado = 'HD';
        else
            H_estimulado = 'HE';
        end
    end

    % Selecionando os dados da Oxy e Desoxy
    data_oxy = nirs_data.oxyData(:,:); % Os dados da Oxy est�o salvos com este nome no arquivo filtrado no NIRS-SPM
    data_des = nirs_data.dxyData(:,:); % Idem para os dados da Desoxy

    % Definindo o diret�rio que cont�m os eventos
    if dir_evento == 2 % Se os eventos estiverem em subpastas para cada participante
        path_evento_participante = [path_evento,'\',codigo];
        addpath(path_evento_participante); % Adicionando o diret�rio que cont�m os eventos do participante em an�lise
    end
    
    % Definindo o nome do arquivo que cont�m os eventos
    arq_eventos = [name_arq,'_fNIRS_Eventos.mat'];

    % Carregando o arquivo com os eventos
    load(arq_eventos);    

    % Inicializando uma c�lula vazia para armazenar os eventos de cada condi��o
    eventos = cell(1,number_conditions); 

    % Acessando os eventos de cada condi��o
    for i = 1:length(letras_eventos)
        letra = letras_eventos{i};
        evento_raw = fNIRS_Eventos.(['Evento_',letra]); % Acessando os eventos da "letra"
        evento_raw = evento_raw*10; % Multiplica por 10 para as casas decimais ficarem corretas

        % Armazenando os eventos de cada condi��o em um elemento da c�lula
        eventos{i} = evento_raw;
    end

    % Acessando o evento baseline, se existir
    if exist('letra_evento_baseline','var') % "exist" verifica se a vari�vel existe
        evento_baseline = fNIRS_Eventos.(['Evento_',letra_evento_baseline])*10;
    end

    % Encontrando o �nicio do baseline do 1� evento OU do baseline �nico
    eventos_matriz = horzcat(eventos{:}); % "horzcat" agrupa horizontalmente os dados de cada elemento da c�lula

    if exist('evento_baseline','var')
        evento_min = evento_baseline; % Neste caso, o 1� evento da coleta ser� o in�cio do baseline
    else
        evento_min = (min(eventos_matriz))-baseline; % Pega o menor valor de "eventos" (que � o 1� evento da coleta) e subtrai X frames
    end

    disp(' ')
    disp('A seguir ser�o plotados os gr�ficos separados por canais, verifique os sinais.')
    disp('Se algum canal estiver ruim, fora os que j� foram identificados, voc� deve exclu�-lo.')
    disp('Pressione "ENTER" para continuar e ap�s a inspe��o de cada figura.')
    pause
    disp(' ')

    % Plotando os dados dos 4 canais para cada hemisf�rio
    fNIRSplots_Channels(freq,name_arq,data_oxy,data_des,evento_min,path_channels)

    % Selecionando os canais com sinais bons (analisar os gr�ficos e olhar a ficha de coleta)
    right_pfc_channels = listdlg('PromptString',{name_arq;' ';'Selecione os canais de interesse:'},...
        'ListString',list_right_channels,'SelectionMode','multiple','Name','HEMISF�RIO DIREITO','ListSize',[250,70]);

    left_pfc_channels = listdlg('PromptString',{name_arq;' ';'Selecione os canais de interesse:'},'ListString',list_left_channels,...
        'SelectionMode','multiple','Name','HEMISF�RIO ESQUERDO','ListSize',[270,70])+4; % +4 para os �ndices serem de 5-8

    % Verificando se o usu�rio selecionou pelo menos 1 canal de cada hemisf�rio
    if isempty(right_pfc_channels) || isempty(left_pfc_channels) % || = ou
        error('� mandat�rio selecionar PELO MENOS 1 canal de cada hemisf�rio. Reinicie a an�lise.')
    end

    channels = [right_pfc_channels left_pfc_channels]; % Agrupando para salvar os canais que foram utilizados

    % Selecionando os dados (Oxy e Desoxy) de cada hemisf�rio
    left_pfc_oxy = data_oxy(:,left_pfc_channels); % Hemisf�rio esquerdo
    left_pfc_des = data_des(:,left_pfc_channels);
    right_pfc_oxy = data_oxy(:,right_pfc_channels); % Hemisf�rio direito
    right_pfc_des = data_des(:,right_pfc_channels);

    % Calculando as m�dias dos canais selecionados - Hemisf�rio esquerdo
    if numel(left_pfc_channels) > 1
        left_pfc_oxy_mean = mean(left_pfc_oxy.'); % "mean" calcula a m�dia dos dados; .' para calcular uma m�dia por linha (frame). Agora os dados est�o em uma linha
        left_pfc_oxy_mean = left_pfc_oxy_mean'; % ' Transp�e "left_pfc_oxy_mean" para uma coluna
        left_pfc_des_mean = mean(left_pfc_des.');
        left_pfc_des_mean = left_pfc_des_mean';
    else % Se apenas 1 canal for selecionado
        left_pfc_oxy_mean = left_pfc_oxy;
        left_pfc_des_mean = left_pfc_des;
    end

    % Calculando as m�dias dos canais selecionados - Hemisf�rio direito
    if numel(right_pfc_channels) > 1
        right_pfc_oxy_mean = mean(right_pfc_oxy.');
        right_pfc_oxy_mean = right_pfc_oxy_mean';
        right_pfc_des_mean = mean(right_pfc_des.');
        right_pfc_des_mean = right_pfc_des_mean';
    else
        right_pfc_oxy_mean = right_pfc_oxy;
        right_pfc_des_mean = right_pfc_des;
    end

    % Agrupando os dados dos hemisf�rios    
    data_areas = [left_pfc_oxy_mean right_pfc_oxy_mean left_pfc_des_mean right_pfc_des_mean];  

    clearvars S filename underline_find codigo arq_eventos letra evento_raw eventos_matriz data_oxy data_des right_pfc_channels...
        left_pfc_channels left_pfc_oxy left_pfc_oxy_mean left_pfc_des left_pfc_des_mean right_pfc_oxy right_pfc_oxy_mean right_pfc_des right_pfc_des_mean
    
    %% Analisando os dados de cada condi��o experimental

    % Inicializando uma matriz de c�lulas vazias para armazenar os resultados
    diffs = cell(numel(janelamentos),number_conditions); % Cada elemento ser� uma matriz 1x6 (Oxy left e right; Desoxy left e right; Oxy e Desoxy dos hemisf�rios combinados)
    
    % Inicializando c�lulas vazias para armazenar as m�dias e desvios-padr�o
    mean_epoch_final = cell(1,number_conditions); % Cada elemento ter� as m�dias de uma condi��o
    std_epoch_final = cell(1,number_conditions); % Cada elemento ter� os desvios-padr�o de uma condi��o

    % Selecionando os dados do baseline �nico (se existir) e calculando a m�dia
    if exist('evento_baseline','var')
        baseline_unico = data_areas(1 + evento_baseline:evento_baseline + baseline,:); % +1 � para desconsiderar o frame do evento
    end

    for z = 1:number_conditions
        name_cond_atual = name_cond{z};
        letra_atual = letras_eventos{z}; % Letra dos eventos da condi��o em an�lise
        eventos_atual = eventos{z}; % Eventos da condi��o em an�lise, est�o em 1 linha e n colunas
        path_figure = paths_figures{z}; % Diret�rio onde o gr�fico da condi��o em an�lise ser� salvo

        % Inicializando uma c�lula vazia para armazenar os dados de cada tentativa
        epoch_cond_atual = cell(1,numel(eventos_atual));
        disp(['Analisando: Condi��o ',name_cond_atual,' - Eventos ',letra_atual])              

        % Analisando as tentativas da condi��o "z"
        for x = 1:numel(eventos_atual)

            % Selecionando os dados da tentativa "x" (baseline + tarefa)
            if exist('baseline_unico','var')
                tarefa = data_areas(1 + eventos_atual(1,x):eventos_atual(1,x)+task_raw,:);
                epoch = [baseline_unico; tarefa]; % Concatenando os dados em uma coluna                
            else
                epoch = data_areas(1 + eventos_atual(1,x)-baseline:eventos_atual(1,x)+task_raw,:);
            end           

            % Encontrando o primeiro valor
            first_epoch = epoch(1,:);

            % Subtraindo o primeiro valor de toda a s�rie temporal para que o gr�fico comece do 0
            epoch_normalized_zero = epoch - first_epoch;

            % Armazenando os dados normalizados de cada tentativa em um elemento da c�lula
            epoch_cond_atual{x} = epoch_normalized_zero;
        end

        % Agrupando horizontalmente cada elemento da c�lula
        epoch_cond_atual = horzcat(epoch_cond_atual{:}); % As colunas 1-4 se referem a 1� tentativa; 5-8 a 2� tentativa e assim em diante...

        % Selecionando os dados normalizados de todas as tentativas para
        epoch_left_pfc_oxy = epoch_cond_atual(:,1:4:end); % Dados da Oxy hemisf. esquerdo est�o na 1�-5�-9�-13� colunas
        epoch_right_pfc_oxy = epoch_cond_atual(:,2:4:end); % Dados da Oxy hemisf. direito est�o na 2�-6�-10�-14� colunas
        epoch_left_pfc_des = epoch_cond_atual(:,3:4:end); % Dados da Desoxy hemisf. esquerdo est�o na 3�-7�-11�-15� colunas
        epoch_right_pfc_des = epoch_cond_atual(:,4:4:end); % Dados da Desoxy hemisf. direito est�o na 4�-8�-12�-16� colunas

        % Calculando m�dias da Oxy e Desoxy ao longo da s�rie temporal
        mean_epoch_left_pfc_oxy = mean(epoch_left_pfc_oxy.');
        mean_epoch_right_pfc_oxy = mean(epoch_right_pfc_oxy.');
        mean_epoch_left_pfc_des = mean(epoch_left_pfc_des.');
        mean_epoch_right_pfc_des = mean(epoch_right_pfc_des.');
        mean_epoch_H_combined_pfc_oxy = mean([epoch_left_pfc_oxy epoch_right_pfc_oxy].'); % M�dia entre os hemisferios
        mean_epoch_H_combined_pfc_des = mean([epoch_left_pfc_des epoch_right_pfc_des].');

        % Agrupando m�dias dos hemisf�rios separados e combinados
        mean_epoch_all = [mean_epoch_left_pfc_oxy' mean_epoch_right_pfc_oxy' mean_epoch_left_pfc_des'...
            mean_epoch_right_pfc_des' mean_epoch_H_combined_pfc_oxy' mean_epoch_H_combined_pfc_des']; % ' Transp�e os dados para colunas

        % Calculando desvios-padr�o da Oxy e Desoxy ao longo da s�rie temporal
        std_epoch_left_pfc_oxy = std(epoch_left_pfc_oxy.'); % "std" calcula o desvio-padr�o; .' para calcular um desvio-padr�o por linha (frames). Aqui os dados est�o em 1 linha
        std_epoch_right_pfc_oxy = std(epoch_right_pfc_oxy.');
        std_epoch_left_pfc_des = std(epoch_left_pfc_des.');
        std_epoch_right_pfc_des = std(epoch_right_pfc_des.');
        std_epoch_H_combined_pfc_oxy = std([epoch_left_pfc_oxy epoch_right_pfc_oxy].'); % Desvio-padr�o entre os hemisferios
        std_epoch_H_combined_pfc_des = std([epoch_left_pfc_des epoch_right_pfc_des].');

        % Agrupando desvios-padr�o dos hemisf�rios separados e combinados
        std_epoch_all = [std_epoch_left_pfc_oxy' std_epoch_right_pfc_oxy' std_epoch_left_pfc_des'...
            std_epoch_right_pfc_des' std_epoch_H_combined_pfc_oxy' std_epoch_H_combined_pfc_des']; % ' Transp�e os dados para colunas

        % Armazenando m�dias e desvios-padr�o de cada condi��o em um elemento das c�lulas        
        mean_epoch_final{z} = mean_epoch_all;
        std_epoch_final{z} = std_epoch_all;

        % Plotando os dados por hemisf�rio e combinados
        fNIRSplots_ConditionsData(freq,name_arq,name_cond_atual,path_figure,mean_epoch_all,std_epoch_all)

        % Selecionando o per�odo baseline
        periodo_baseline = mean_epoch_all(1 + atraso_fisiologico:baseline - baseline_correction,:); % Excluindo atraso fisiol�gico e antecipa��o a tarefa

        % Calculando a m�dia do per�odo baseline
        mean_periodo_baseline = mean(periodo_baseline);

        % Selecionando o per�odo da tarefa em cada janelamento
        periodo_tarefa_early = mean_epoch_all(1 + frame_start_task:frame_start_task + task_janelada,:);

        if task_correction == 0 % Se o usu�rio n�o quis excluir nenhum segundo antes do t�rmino da tarefa            
            periodo_tarefa_late = mean_epoch_all(1 + frame_start_task_late:end,:); % "Late" ficar� com 5s a mais do que o "Early"
            periodo_tarefa_total = mean_epoch_all(1 + frame_start_task:end,:);
        else
            periodo_tarefa_late = mean_epoch_all(1 + frame_start_task_late:end - task_correction,:);
            periodo_tarefa_total = mean_epoch_all(1 + frame_start_task:end - task_correction,:);
        end

        % Calculando a m�dia do per�odo da tarefa em cada janelamento
        mean_periodo_tarefa_early = mean(periodo_tarefa_early);
        mean_periodo_tarefa_late = mean(periodo_tarefa_late);
        mean_periodo_tarefa_total = mean(periodo_tarefa_total);

        % Calculando a diferen�a entre os per�odos (m�dia da tarefa - m�dia do baseline)
        diffs{1,z} = mean_periodo_tarefa_early - mean_periodo_baseline;
        diffs{2,z} = mean_periodo_tarefa_late - mean_periodo_baseline;
        diffs{3,z} = mean_periodo_tarefa_total - mean_periodo_baseline;
    end
    
    clearvars epoch_cond_atual tarefa epoch first_epoch epoch_normalized_zero epoch_left_pfc_oxy epoch_right_pfc_oxy epoch_left_pfc_des...
        epoch_right_pfc_des mean_epoch_left_pfc_oxy mean_epoch_right_pfc_oxy mean_epoch_left_pfc_des mean_epoch_right_pfc_des...
        mean_epoch_H_combined_pfc_oxy mean_epoch_H_combined_pfc_des std_epoch_left_pfc_oxy std_epoch_right_pfc_oxy std_epoch_left_pfc_des...
        std_epoch_right_pfc_des std_epoch_H_combined_pfc_oxy std_epoch_H_combined_pfc_des

    %% Salvando os resultados

    % Abrindo o diret�rio onde os resultados ser�o salvos
    cd(path_save)
    disp(' ')
    disp('Salvando os dados...')
    pause(1)

    % Agrupando horizontalmente os dados de todas as condi��es
    mean_epoch_final = horzcat(mean_epoch_final{:});
    std_epoch_final = horzcat(std_epoch_final{:});
    diff_early = horzcat(diffs{1,:});
    diff_late = horzcat(diffs{2,:});
    diff_total = horzcat(diffs{3,:});

    % Agrupando horizontalmente as legendas das vari�veis
    parameters_means_stds_final = horzcat(parameters_means_stds{:});
    parameters_early = horzcat(parameters_raw{1,:});
    parameters_late = horzcat(parameters_raw{2,:});
    parameters_total = horzcat(parameters_raw{3,:});

    % Criando tabelas com os resultados e legendas
    results_means = array2table(mean_epoch_final,'VariableNames',parameters_means_stds_final); % "array2table" = transforma uma matriz em uma tabela
    results_stds = array2table(std_epoch_final,'VariableNames',parameters_means_stds_final);
    results_early = array2table(diff_early,'VariableNames',parameters_early); 
    results_late = array2table(diff_late,'VariableNames',parameters_late);
    results_total = array2table(diff_total,'VariableNames',parameters_total);

    % Armazenando as tabelas em uma estrutura de dados
    fNIRS_Results = struct('Channels',channels,'Means',results_means,'Stds',results_stds,'Early',results_early,'Late',results_late,'Total',results_total);

    % Criando o nome do arquivo e salvando a estrutura
    if exist('H_estimulado','var')
        name_arq_results = [name_arq,'_',H_estimulado,'_fNIRS_Results'];
    else 
        name_arq_results = [name_arq,'_fNIRS_Results'];
    end

    % Salvando a estrutura de dados em formato ".mat"    
    save(name_arq_results,'fNIRS_Results');   
  
    % Retornando ao diret�rio que cont�m os arquivos (necess�rio para a rotina encontrar o pr�ximo arquivo para an�lise)
    disp(' ')
    disp('Pr�ximo participante...')
    disp(' ')
    cd(path_analise)    
end

cd(path_save)
clear; clc
disp ('Fim da an�lise da fNIRS!!!');
disp ('OBRIGADO PELA COLABORA��O!');