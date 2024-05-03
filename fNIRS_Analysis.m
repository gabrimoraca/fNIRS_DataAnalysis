%% ROTINA DESENVOLVIDA PARA ANÁLISE DOS DADOS DA fNIRS
% Desenvolvedor: Gabriel Antonio Gazziero Moraca
% Abril de 2024

%% Instruções ao usuário
clear; clc
disp('Antes de começar a análise, se atende aos itens abaixo:')
disp(' ')
disp('- Os eventos de interesse devem ter sido encontrados por meio da rotina "fNIRS_Find_Eventos.m".')
disp('- Os dados devem ter sido processados e filtrados CORRETAMENTE no NIRS-SPM.')
disp('- Os arquivos "fNIRSplots_Channels.m" e "fNIRSplots_ConditionsData.m" são funções que servem para plotar os dados.')
disp('- Esta rotina e as funções que plotam os dados DEVEM estar no mesmo diretório. ')
disp('- Os dados serão analisados em 3 janelamentos: "Early", "Late" e "Total".')
disp('- Serão criadas figuras para cada condição experimental, crie diretórios para salvá-las.')
disp('- Nunca digite números por extenso (um, dois...) quando for solicitada a entrada de valores.')
disp('- Use abreviações para nomear as condições experimentais (AR - andar rápido; TD - tarefa dupla, etc).')
disp('- Por fim, você deve saber, previamente:')
disp('1) Os canais 1-4 são do hemisfério direito e os canais 5-8 são do hesmifério esquerdo.')
disp('2) A quantidade de condições experimentais.')
disp('3) Os eventos de cada condição e do baseline (se houver).')
disp('4) A duração total dos períodos baseline e tarefa.')
disp('5) A duração da tarefa em cada janelamento.')
disp('6) Quanto tempo do baseline e da tarefa serão excluídos e analisados.');
disp('7) Qual foi o hemisfério estimulado em cada participante, se houve aplicação da ETCC em apenas um hemisfério.')
disp(' ')
disp('Pressione ENTER para iniciar a análise.')
pause
clc

%% Adicionando informações sobre o protocolo experimental do usuário

% Definindo a frequência de coleta em Hz
freq = 10;

% Definindo a quantidade de condições experimentais e o diretório que contém as rotinas
options = {'Digite a quantidade de condições experimentais:' 'Digite o diretório que contém as rotinas para análise da fNIRS:'};
protocol1 = strtrim(inputdlg(options,'Informações sobre o protocolo',[1 70])); % "inputdlg" cria uma caixa de diálogo; "strtrim" retira espaços antes e depois da string

% Selecionando a quantidade de condições
number_conditions = str2double(protocol1{1}); % "str2double" transforma uma string em número

% Adicionando o diretório que contém as rotinas para analisar os dados
path_scripts = addpath(protocol1{2}); % "addpath" adiciona um diretório na rotina

% Verificando se o usuário definiu a quantidade de condições
if ~isnumeric(number_conditions) % "~isnumeric" verifica se a variável não é um número
    error('É mandatório definir a quantidade de condições experimentais. Reinicie a análise.'); % "error" interrompe a rotina com uma mensagem de erro
end

% Inicializando células vazias para armazenar as instruções da caixa de diálogo do protocolo
questions_protocol = cell(2,number_conditions);

% Criando as instruções da caixa de diálogo do protocolo
for i = 1:number_conditions
    prompt1 = sprintf('Digite o nome da %dª condição:',i); % "sprintf" formata uma string com texto e numeros
    prompt2 = sprintf('Digite a letra dos eventos da %dª condição:',i);

    % Armazenando cada instrução em um elemento da célula
    questions_protocol{1,i} = prompt1;
    questions_protocol{2,i} = prompt2;
end

% Definindo o nome das condições e a letras dos eventos
protocol2 = strtrim(inputdlg(questions_protocol,'Informações sobre o protocolo',[1 70]));

% Verificando se o usuário preencheu todos os campos da caixa de diálogo do protocolo
if any(cellfun('isempty',protocol2)) % "cellfun" aplica a função "isempty" (é vazia) em cada elemento da célula; % "any" retorna verdadeiro se pelo menos 1 elemento estiver vazio
    error('É mandatório nomear todas as condições experimentais e letras dos eventos. Reinicie a análise.');
end

% Selecionando os nomes das condições e as letras
name_cond = protocol2(1:2:end);
letras_eventos = upper(protocol2(2:2:end)); % "upper" transforma a string em maiúscula

% Definindo como os eventos estão organizados
options = {'Em uma única pasta' 'Em subpastas para cada participante'};
questions_eventos = {'Como os arquivos dos eventos estão organizados?';' ';'Selecione uma das opções abaixo:'};
dir_evento = listdlg('PromptString',questions_eventos,'ListString',options,'SelectionMode','single',...
    'Name','Eventos da fNIRS','ListSize',[250 100]); % "listdlg" cria uma caixa de diálogo com uma lista de opções para serem selecionadas e retorna os índices dessa lista

% Definindo se houve aplicação da ETCC
etcc_pergunta = questdlg('Houve estimulação em um hemisfério cerebral específico?','Aplicação da ETCC','Sim','Não','Sim'); % "questdlg" cria uma caixa de diálogo com uma pergunta e botões de resposta

% Inicializando célula vazia para armazenar algumas instruções da caixa de diálogo dos diretórios
questions_figures = cell(1,number_conditions);

% Criando as instruções da caixa de diálogo dos diretórios
if dir_evento == 1
    questions_eventos = {'Digite o diretório que contém os eventos dos participantes:'};
else
    questions_eventos = {'Os eventos foram salvos em subpastas para cada participante. Digite o diretório que contém as subpastas:'};
end

for i = 1:number_conditions
    cond = name_cond{i};
    prompt = sprintf('Digite o diretório para salvar os gráficos da condição %s:',cond);
    questions_figures{i} = prompt;
end

questions_channels_data = {'Digite o diretório onde os gráficos dos canais serão salvos:' 'Digite o diretório que contém os dados filtrados no SPM:'...
    'Digite o diretório onde os dados analisados serão salvos:'};
questions_paths = [questions_eventos questions_figures questions_channels_data];

% Definindo os diretórios
paths = strtrim(inputdlg(questions_paths,'Definindo os diretórios',[1 67]));

% Verificando se o usuário preencheu os campos com diretórios existentes
if any(~cellfun(@isfolder,paths)) % "cellfun" aplica "isfolder" (é um diretório) em cada elemento da célula; "~" nega o resultado da função (ou seja, se um elemento for um diretório, ela retorna falso); 
    % "any" retorna verdadeiro se pelo menos 1 elemento não for um diretório
    error('É mandatório definir diretórios existentes. Reinicie a análise.');
end

% Selecionando os diretórios
path_evento = paths{1};
addpath(path_evento) % Adicionando o diretório que contém os eventos (ou as subpastas dos participantes)
paths_figures = paths(2:1:end-3); % -3 porque os últimos 3 elementos serão diretórios referentes aos canais e dados e não as condições
path_channels = paths{end-2};
path_analise = paths{end-1};
path_save = paths{end};

clearvars questions_protocol protocol1 protocol2 prompt1 prompt2 options questions_eventos prompt questions_figures questions_channels_data questions_paths paths cond

%% Adicionando informações para analisar os dados da fNIRS

% Definindo se existe um evento baseline e a letra deste evento
baseline_pergunta = questdlg('Há um evento baseline no seu protocolo?',' ','Sim','Não','Não'); 

if baseline_pergunta == "Sim"    
    letra_evento_baseline = strtrim(upper(input('Digite a letra que identifica o baseline: ','s'))); % "input" solicita entrada do usuário
end

% Criando as instruções da caixa de diálogo do baseline
questions_baseline = {'Digite a duração TOTAL realizado na coleta, em segundos:' 'Digite quantos segundos, imediatamente ANTES do INÍCIO da tarefa, serão excluídos:'};

% Definindo a duração do baseline durante a coleta e o quanto será analisado
measures_baseline = str2double(inputdlg(questions_baseline,'Informações sobre o BASELINE',[1 70]));

% Verificando se o usuário preencheu todos os campos da caixa de diálogo do baseline com números
if any(isnan(measures_baseline)) % "isnan" verifica se algum elemento da matriz numérica é NaN (not a number); "any" retorna verdadeiro se pelo menos 1 elemento for NaN
    error('É mandatório preencher todos os campos referentes ao Baseline. Reinicie a análise.');
end

% Selecionando as medidas do baseline
baseline = measures_baseline(1)*freq; % multiplica por "freq" para passar pra frames
baseline_correction = measures_baseline(2)*freq;

% Criando as instruções da caixa de diálogo da tarefa
questions_tarefa = {'Digite a duração do atraso fisiológico, em segundos:' 'Digite o tempo TOTAL realizado na coleta, em segundos:'...
    'Digite quantos segundos, ANTES do TÉRMINO da tarefa, serão excluídos. Se não for excluir, digite 0:'...
    'Digite a duração dos janelamentos "Early" e "Late", em segundos:'};

% Definindo durações da tarefa, atraso fisiológico e janelamentos
measures_tarefa = str2double(inputdlg(questions_tarefa,'Informações sobre a TAREFA',[1 70]));

% Verificando se o usuário preencheu todos os campos da caixa de diálogo da tarefa com números
if any(isnan(measures_tarefa))
    error('É mandatório preencher todos os campos referentes ao Baseline. Reinicie a análise.');
end

% Selecionando as medidas da tarefa
atraso_fisiologico = measures_tarefa(1)*freq;
task_raw = measures_tarefa(2)*freq;
task_correction = measures_tarefa(3)*freq;
task_janelada = measures_tarefa(4)*freq;
frame_start_task = baseline + atraso_fisiologico; % Representa o início da tarefa, desconsiderando o atraso fisiológico
frame_start_task_late = frame_start_task + task_janelada; % Representa o início da tarefa no janelamento late

% Definindo os nomes dos janelamentos que serão analisados
janelamentos = {'Early' 'Late' 'Total'};

% Inicializando células vazias para armazenar as legendas das variáveis
parameters_raw = cell(numel(janelamentos),number_conditions); % "numel" retorna o número de elementos da célula
parameters_means_stds = cell(1,number_conditions);

% Definindo as legendas das tabelas que serão salvas
for y = 1:number_conditions
    cond = name_cond{y};

    for z = 1:numel(janelamentos)
        janela = janelamentos{z};

        % Armazenando cada legenda em um elemento da célula
        parameters_raw{z,y} = {['Left_Oxy_' janela '_' cond] ['Right_Oxy_' janela '_' cond] ['Left_Des_' janela '_' cond]...
            ['Right_Des_' janela '_' cond] ['Both_Oxy_' janela '_' cond] ['Both_Des_' janela '_' cond]};
    end

    % Armazenando cada legenda em um elemento da célula
    parameters_means_stds{y} = {['Left_Oxy_' cond] ['Right_Oxy_' cond] ['Left_Des_' cond] ['Right_Des_' cond] ['Both_Oxy_' cond] ['Both_Des_' cond]};
end

% Definindo as legendas dos canais
list_right_channels = {'Canal 1' 'Canal 2' 'Canal 3' 'Canal 4'};
list_left_channels = {'Canal 5' 'Canal 6' 'Canal 7' 'Canal 8'};

clc
clearvars baseline_pergunta questions_baseline measures_baseline questions_tarefa measures_tarefa cond janela

%% Analisando os dados pré-processados da fNIRS

% Abrindo o diretório que contém os arquivos
cd(path_analise)

% Selecionando os arquivos de interesse (.mat)
[arquivos,path_analise] = uigetfile('.mat','multiselect','on','Selecione os arquivos para análise'); % "uigetfile" cria uma janela de diálogo para selecionar arquivos que possuem a extensão especificada

for narq = 1:length(arquivos)
    S = warning('OFF');

    % Carregando o arquivo de interesse
    filename = arquivos{narq};
    load(filename);

    % Criando o nome do participante
    underline_find = strfind(filename,'_'); % "strfind" retorna um vetor com as posições dos "_" em "filename"
    underline_find_max = max(underline_find); % "max" retorna o maior índice de "underline_find", que é a última ocorrência de "_"
    underline_find_min = min(underline_find); % "min" retorna o menor índice de "underline_find", que é a primeira ocorrência de "_"
    name_arq = filename(1,1:underline_find_max-1); % "name_arq" será do 1º caractere de "filename" até o caractere antes do último "_"
    codigo = filename(1,1:underline_find_min-1); % "código" será do 1º caractere até o caractere antes do 1º "_"
    disp(name_arq)

    % Identificando o hemisfério estimulado, se houve aplicação da ETCC em um dos hemisférios
    if etcc_pergunta == "Sim"        
        H_estimulado = questdlg(['Qual hemisfério foi estimulado no ' name_arq '?'],'Aplicação da ETCC','Esquerdo','Direito','Direito');
        
        if H_estimulado == "Direito"
            H_estimulado = 'HD';
        else
            H_estimulado = 'HE';
        end
    end

    % Selecionando os dados da Oxy e Desoxy
    data_oxy = nirs_data.oxyData(:,:); % Os dados da Oxy estão salvos com este nome no arquivo filtrado no NIRS-SPM
    data_des = nirs_data.dxyData(:,:); % Idem para os dados da Desoxy

    % Definindo o diretório que contém os eventos
    if dir_evento == 2 % Se os eventos estiverem em subpastas para cada participante
        path_evento_participante = [path_evento,'\',codigo];
        addpath(path_evento_participante); % Adicionando o diretório que contém os eventos do participante em análise
    end
    
    % Definindo o nome do arquivo que contém os eventos
    arq_eventos = [name_arq,'_fNIRS_Eventos.mat'];

    % Carregando o arquivo com os eventos
    load(arq_eventos);    

    % Inicializando uma célula vazia para armazenar os eventos de cada condição
    eventos = cell(1,number_conditions); 

    % Acessando os eventos de cada condição
    for i = 1:length(letras_eventos)
        letra = letras_eventos{i};
        evento_raw = fNIRS_Eventos.(['Evento_',letra]); % Acessando os eventos da "letra"
        evento_raw = evento_raw*10; % Multiplica por 10 para as casas decimais ficarem corretas

        % Armazenando os eventos de cada condição em um elemento da célula
        eventos{i} = evento_raw;
    end

    % Acessando o evento baseline, se existir
    if exist('letra_evento_baseline','var') % "exist" verifica se a variável existe
        evento_baseline = fNIRS_Eventos.(['Evento_',letra_evento_baseline])*10;
    end

    % Encontrando o ínicio do baseline do 1º evento OU do baseline único
    eventos_matriz = horzcat(eventos{:}); % "horzcat" agrupa horizontalmente os dados de cada elemento da célula

    if exist('evento_baseline','var')
        evento_min = evento_baseline; % Neste caso, o 1º evento da coleta será o início do baseline
    else
        evento_min = (min(eventos_matriz))-baseline; % Pega o menor valor de "eventos" (que é o 1º evento da coleta) e subtrai X frames
    end

    disp(' ')
    disp('A seguir serão plotados os gráficos separados por canais, verifique os sinais.')
    disp('Se algum canal estiver ruim, fora os que já foram identificados, você deve excluí-lo.')
    disp('Pressione "ENTER" para continuar e após a inspeção de cada figura.')
    pause
    disp(' ')

    % Plotando os dados dos 4 canais para cada hemisfério
    fNIRSplots_Channels(freq,name_arq,data_oxy,data_des,evento_min,path_channels)

    % Selecionando os canais com sinais bons (analisar os gráficos e olhar a ficha de coleta)
    right_pfc_channels = listdlg('PromptString',{name_arq;' ';'Selecione os canais de interesse:'},...
        'ListString',list_right_channels,'SelectionMode','multiple','Name','HEMISFÉRIO DIREITO','ListSize',[250,70]);

    left_pfc_channels = listdlg('PromptString',{name_arq;' ';'Selecione os canais de interesse:'},'ListString',list_left_channels,...
        'SelectionMode','multiple','Name','HEMISFÉRIO ESQUERDO','ListSize',[270,70])+4; % +4 para os índices serem de 5-8

    % Verificando se o usuário selecionou pelo menos 1 canal de cada hemisfério
    if isempty(right_pfc_channels) || isempty(left_pfc_channels) % || = ou
        error('É mandatório selecionar PELO MENOS 1 canal de cada hemisfério. Reinicie a análise.')
    end

    channels = [right_pfc_channels left_pfc_channels]; % Agrupando para salvar os canais que foram utilizados

    % Selecionando os dados (Oxy e Desoxy) de cada hemisfério
    left_pfc_oxy = data_oxy(:,left_pfc_channels); % Hemisfério esquerdo
    left_pfc_des = data_des(:,left_pfc_channels);
    right_pfc_oxy = data_oxy(:,right_pfc_channels); % Hemisfério direito
    right_pfc_des = data_des(:,right_pfc_channels);

    % Calculando as médias dos canais selecionados - Hemisfério esquerdo
    if numel(left_pfc_channels) > 1
        left_pfc_oxy_mean = mean(left_pfc_oxy.'); % "mean" calcula a média dos dados; .' para calcular uma média por linha (frame). Agora os dados estão em uma linha
        left_pfc_oxy_mean = left_pfc_oxy_mean'; % ' Transpõe "left_pfc_oxy_mean" para uma coluna
        left_pfc_des_mean = mean(left_pfc_des.');
        left_pfc_des_mean = left_pfc_des_mean';
    else % Se apenas 1 canal for selecionado
        left_pfc_oxy_mean = left_pfc_oxy;
        left_pfc_des_mean = left_pfc_des;
    end

    % Calculando as médias dos canais selecionados - Hemisfério direito
    if numel(right_pfc_channels) > 1
        right_pfc_oxy_mean = mean(right_pfc_oxy.');
        right_pfc_oxy_mean = right_pfc_oxy_mean';
        right_pfc_des_mean = mean(right_pfc_des.');
        right_pfc_des_mean = right_pfc_des_mean';
    else
        right_pfc_oxy_mean = right_pfc_oxy;
        right_pfc_des_mean = right_pfc_des;
    end

    % Agrupando os dados dos hemisférios    
    data_areas = [left_pfc_oxy_mean right_pfc_oxy_mean left_pfc_des_mean right_pfc_des_mean];  

    clearvars S filename underline_find codigo arq_eventos letra evento_raw eventos_matriz data_oxy data_des right_pfc_channels...
        left_pfc_channels left_pfc_oxy left_pfc_oxy_mean left_pfc_des left_pfc_des_mean right_pfc_oxy right_pfc_oxy_mean right_pfc_des right_pfc_des_mean
    
    %% Analisando os dados de cada condição experimental

    % Inicializando uma matriz de células vazias para armazenar os resultados
    diffs = cell(numel(janelamentos),number_conditions); % Cada elemento será uma matriz 1x6 (Oxy left e right; Desoxy left e right; Oxy e Desoxy dos hemisférios combinados)
    
    % Inicializando células vazias para armazenar as médias e desvios-padrão
    mean_epoch_final = cell(1,number_conditions); % Cada elemento terá as médias de uma condição
    std_epoch_final = cell(1,number_conditions); % Cada elemento terá os desvios-padrão de uma condição

    % Selecionando os dados do baseline único (se existir) e calculando a média
    if exist('evento_baseline','var')
        baseline_unico = data_areas(1 + evento_baseline:evento_baseline + baseline,:); % +1 é para desconsiderar o frame do evento
    end

    for z = 1:number_conditions
        name_cond_atual = name_cond{z};
        letra_atual = letras_eventos{z}; % Letra dos eventos da condição em análise
        eventos_atual = eventos{z}; % Eventos da condição em análise, estão em 1 linha e n colunas
        path_figure = paths_figures{z}; % Diretório onde o gráfico da condição em análise será salvo

        % Inicializando uma célula vazia para armazenar os dados de cada tentativa
        epoch_cond_atual = cell(1,numel(eventos_atual));
        disp(['Analisando: Condição ',name_cond_atual,' - Eventos ',letra_atual])              

        % Analisando as tentativas da condição "z"
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

            % Subtraindo o primeiro valor de toda a série temporal para que o gráfico comece do 0
            epoch_normalized_zero = epoch - first_epoch;

            % Armazenando os dados normalizados de cada tentativa em um elemento da célula
            epoch_cond_atual{x} = epoch_normalized_zero;
        end

        % Agrupando horizontalmente cada elemento da célula
        epoch_cond_atual = horzcat(epoch_cond_atual{:}); % As colunas 1-4 se referem a 1ª tentativa; 5-8 a 2º tentativa e assim em diante...

        % Selecionando os dados normalizados de todas as tentativas para
        epoch_left_pfc_oxy = epoch_cond_atual(:,1:4:end); % Dados da Oxy hemisf. esquerdo estão na 1º-5º-9º-13º colunas
        epoch_right_pfc_oxy = epoch_cond_atual(:,2:4:end); % Dados da Oxy hemisf. direito estão na 2º-6º-10º-14º colunas
        epoch_left_pfc_des = epoch_cond_atual(:,3:4:end); % Dados da Desoxy hemisf. esquerdo estão na 3º-7º-11º-15º colunas
        epoch_right_pfc_des = epoch_cond_atual(:,4:4:end); % Dados da Desoxy hemisf. direito estão na 4º-8º-12º-16º colunas

        % Calculando médias da Oxy e Desoxy ao longo da série temporal
        mean_epoch_left_pfc_oxy = mean(epoch_left_pfc_oxy.');
        mean_epoch_right_pfc_oxy = mean(epoch_right_pfc_oxy.');
        mean_epoch_left_pfc_des = mean(epoch_left_pfc_des.');
        mean_epoch_right_pfc_des = mean(epoch_right_pfc_des.');
        mean_epoch_H_combined_pfc_oxy = mean([epoch_left_pfc_oxy epoch_right_pfc_oxy].'); % Média entre os hemisferios
        mean_epoch_H_combined_pfc_des = mean([epoch_left_pfc_des epoch_right_pfc_des].');

        % Agrupando médias dos hemisférios separados e combinados
        mean_epoch_all = [mean_epoch_left_pfc_oxy' mean_epoch_right_pfc_oxy' mean_epoch_left_pfc_des'...
            mean_epoch_right_pfc_des' mean_epoch_H_combined_pfc_oxy' mean_epoch_H_combined_pfc_des']; % ' Transpõe os dados para colunas

        % Calculando desvios-padrão da Oxy e Desoxy ao longo da série temporal
        std_epoch_left_pfc_oxy = std(epoch_left_pfc_oxy.'); % "std" calcula o desvio-padrão; .' para calcular um desvio-padrão por linha (frames). Aqui os dados estão em 1 linha
        std_epoch_right_pfc_oxy = std(epoch_right_pfc_oxy.');
        std_epoch_left_pfc_des = std(epoch_left_pfc_des.');
        std_epoch_right_pfc_des = std(epoch_right_pfc_des.');
        std_epoch_H_combined_pfc_oxy = std([epoch_left_pfc_oxy epoch_right_pfc_oxy].'); % Desvio-padrão entre os hemisferios
        std_epoch_H_combined_pfc_des = std([epoch_left_pfc_des epoch_right_pfc_des].');

        % Agrupando desvios-padrão dos hemisférios separados e combinados
        std_epoch_all = [std_epoch_left_pfc_oxy' std_epoch_right_pfc_oxy' std_epoch_left_pfc_des'...
            std_epoch_right_pfc_des' std_epoch_H_combined_pfc_oxy' std_epoch_H_combined_pfc_des']; % ' Transpõe os dados para colunas

        % Armazenando médias e desvios-padrão de cada condição em um elemento das células        
        mean_epoch_final{z} = mean_epoch_all;
        std_epoch_final{z} = std_epoch_all;

        % Plotando os dados por hemisfério e combinados
        fNIRSplots_ConditionsData(freq,name_arq,name_cond_atual,path_figure,mean_epoch_all,std_epoch_all)

        % Selecionando o período baseline
        periodo_baseline = mean_epoch_all(1 + atraso_fisiologico:baseline - baseline_correction,:); % Excluindo atraso fisiológico e antecipação a tarefa

        % Calculando a média do período baseline
        mean_periodo_baseline = mean(periodo_baseline);

        % Selecionando o período da tarefa em cada janelamento
        periodo_tarefa_early = mean_epoch_all(1 + frame_start_task:frame_start_task + task_janelada,:);

        if task_correction == 0 % Se o usuário não quis excluir nenhum segundo antes do término da tarefa            
            periodo_tarefa_late = mean_epoch_all(1 + frame_start_task_late:end,:); % "Late" ficará com 5s a mais do que o "Early"
            periodo_tarefa_total = mean_epoch_all(1 + frame_start_task:end,:);
        else
            periodo_tarefa_late = mean_epoch_all(1 + frame_start_task_late:end - task_correction,:);
            periodo_tarefa_total = mean_epoch_all(1 + frame_start_task:end - task_correction,:);
        end

        % Calculando a média do período da tarefa em cada janelamento
        mean_periodo_tarefa_early = mean(periodo_tarefa_early);
        mean_periodo_tarefa_late = mean(periodo_tarefa_late);
        mean_periodo_tarefa_total = mean(periodo_tarefa_total);

        % Calculando a diferença entre os períodos (média da tarefa - média do baseline)
        diffs{1,z} = mean_periodo_tarefa_early - mean_periodo_baseline;
        diffs{2,z} = mean_periodo_tarefa_late - mean_periodo_baseline;
        diffs{3,z} = mean_periodo_tarefa_total - mean_periodo_baseline;
    end
    
    clearvars epoch_cond_atual tarefa epoch first_epoch epoch_normalized_zero epoch_left_pfc_oxy epoch_right_pfc_oxy epoch_left_pfc_des...
        epoch_right_pfc_des mean_epoch_left_pfc_oxy mean_epoch_right_pfc_oxy mean_epoch_left_pfc_des mean_epoch_right_pfc_des...
        mean_epoch_H_combined_pfc_oxy mean_epoch_H_combined_pfc_des std_epoch_left_pfc_oxy std_epoch_right_pfc_oxy std_epoch_left_pfc_des...
        std_epoch_right_pfc_des std_epoch_H_combined_pfc_oxy std_epoch_H_combined_pfc_des

    %% Salvando os resultados

    % Abrindo o diretório onde os resultados serão salvos
    cd(path_save)
    disp(' ')
    disp('Salvando os dados...')
    pause(1)

    % Agrupando horizontalmente os dados de todas as condições
    mean_epoch_final = horzcat(mean_epoch_final{:});
    std_epoch_final = horzcat(std_epoch_final{:});
    diff_early = horzcat(diffs{1,:});
    diff_late = horzcat(diffs{2,:});
    diff_total = horzcat(diffs{3,:});

    % Agrupando horizontalmente as legendas das variáveis
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
  
    % Retornando ao diretório que contém os arquivos (necessário para a rotina encontrar o próximo arquivo para análise)
    disp(' ')
    disp('Próximo participante...')
    disp(' ')
    cd(path_analise)    
end

cd(path_save)
clear; clc
disp ('Fim da análise da fNIRS!!!');
disp ('OBRIGADO PELA COLABORAÇÃO!');