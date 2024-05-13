%% ROTINA DESENVOLVIDA PARA AGRUPAR OS DADOS DA fNIRS
% Desenvolvedor: Gabriel Antonio Gazziero Moraca
% Abril de 2024

%% Instruções ao usuário
clear; clc
instructions = char({'Para a rotina funcionar corretamente, se atente aos pontos abaixo:';' ';...
    '1) Os dados da fNIRS devem ter sido analisados por meio da rotina "fNIRS_Analysis.m".';...
    '2) Todos os dados, previamente analisados, devem estar em uma única pasta, independente do número de grupos.';...
    '3) A rotina agrupará os dados de acordo com as condições e janelamento de interesse, salvando-os em arquivos Excel.';...
    '4) É essencial saber a quantidade e os nomes das condições experimentais, momentos de avaliação e intervenções aplicadas.';...
    '5) Nunca digite números por extenso (um, dois...) quando for solicitada a entrada de valores.';...
    '6) Use abreviações para nomear as condições experimentais (AR - andar rápido; TD - tarefa dupla, etc).';...
    '7) Se não houve intervenção no estudo, deixe em o branco o campo que nomeia a intervenção.';...
    '8) Se houve somente 1 momento de avaliação, deixe em o branco o campo que nomeia o momento.';' ';'Pressione ENTER para iniciar a análise.';}); % "char" converte a célula em uma matriz de caracteres
disp(instructions)
pause
clc

%% Adicionando informações sobre o protocolo experimental do usuário

% Definindo a quantidade de condições experimentais, momentos e intervenções
questions_protocol_numbers = {'Digite o número de condições experimentais:' 'Digite o número de momentos de avaliação:'...
    'Digite o número de intervenções. Se não houve intervenções, digite 1:'};
protocol = str2double(inputdlg(questions_protocol_numbers,'Informações sobre o protocolo',[1,75])); % "inputdlg" cria uma caixa de diálogo; "str2double" transforma uma string em número

% Verificando se o usuário preencheu todos os campos da caixa de diálogo do protocolo com números
if any(isnan(protocol)) % "isnan" verifica se algum elemento da matriz numérica é NaN (not a number); "any" retorna verdadeiro se pelo menos 1 elemento for NaN
    error('É mandatório definir a quantidade de condições experimentais, momento e intervenções. Reinicie a análise.'); % "error" interrompe a rotina com uma mensagem de erro
end

% Selecionando as quantidades de condições, momentos e intervenções
n_conds = protocol(1);
n_momentos = protocol(2);
n_interventions = protocol(3);

% Inicializando células vazias para armazenar as instruções da caixa de diálogo
questions_conds = cell(1,n_conds); 
questions_momentos = cell(1,n_momentos);
questions_interventions = cell(1,n_interventions);

% Criando as instruções da caixa de diálogo do protocolo
for i = 1:n_conds
    prompt = sprintf('Digite o nome da condição %d:',i); % "sprintf" formata uma string com texto e numeros
    questions_conds{i} = prompt; % Armazenando cada instrução em um elemento da célula
end

for i = 1:n_momentos
    prompt = sprintf('Digite o nome do momento %d:',i);
    questions_momentos{i} = prompt;
end

for i = 1:n_interventions
    prompt = sprintf('Digite o nome da intervenção %d:',i);
    questions_interventions{i} = prompt;
end

% Definindo os nomes das condições, momentos e intervenções
questions_protocol_names = [questions_conds questions_momentos questions_interventions];
all_names = strtrim(inputdlg(questions_protocol_names,'Informações sobre o protocolo',[1,70])); % "strtrim" retira espaços antes e depois da string

% Selecionando os nomes de todas as condições, momentos e intervenções
names_conds = all_names(1:n_conds);
names_momentos = all_names(1 + n_conds:end - n_interventions);
names_interventions = all_names(1 + n_conds + n_momentos:end);

% Definindo os diretórios 
questions_paths = {'Digite o diretório que contém os dados analisados:' 'Digite o diretório onde os resultados agrupados serão salvos:'};
all_paths = strtrim(inputdlg(questions_paths,'Definindo os diretórios',[1,70]));

% Verificando se o usuário preencheu todos os campos com diretórios existentes
if any(~cellfun(@isfolder,all_paths)) % "cellfun" aplica "isfolder" (é um diretório) em cada elemento da célula; "~" nega o resultado da função (ou seja, se um elemento for um diretório, ela retorna falso); 
    % "any" retorna verdadeiro se pelo menos 1 elemento não for um diretório
    error('É mandatório definir diretórios existentes. Reinicie a análise.');
end

% Selecionando os diretórios
path_analise = all_paths{1};
path_save = all_paths{2};

clearvars questions_protocol_numbers protocol questions_conds questions_momentos questions_interventions questions_protocol_names...
    prompt all_names questions_paths all_paths

%% Selecionando os arquivos que contém os dados analisados da fNIRS

% Abrindo o diretório que contém os arquivos
cd(path_analise)

% Listando os arquivos contidos no diretório
list_arq = dir('*.mat'); % "dir" retorna informações (nome, local, data...) sobre os arquivos que possuem a extensão especificada

% Selecionando os nomes dos arquivos
names_arq = {list_arq.name}'; % ' Transpõe os dados para uma coluna (estavam em uma linha)

% Inicializando uma matriz de células vazias para armazenar os nomes dos arquivos
arquivos_cond = cell(n_interventions*n_momentos,1); % Em cada célula haverá os nomes dos arquivos de um conjunto intervenção-momento
contador = 1; % Servirá de índice para armazenar corretamente os nomes dos arquivos em "arquivos_cond"

% Selecionando os arquivos de interesse conforme cada intervenção-momento
for w = 1:n_interventions
    intervention = names_interventions{w};

    for x = 1:n_momentos
        momento = names_momentos{x};

        % Criando a instrução da caixa de diálogo
        if isempty(intervention) || isempty(momento) % "isempty" verifica se a variável está vazia; || = OU
            instrucao = {'Selecione os arquivos de interesse:'};
        else
            instrucao = {'Selecione os arquivos das condições abaixo:';['- Intervenção: ' intervention];['- Momento: ' momento]};
        end

        % Selecionando os arquivos (índices dos arquivos)
        indices_arq = listdlg('PromptString',instrucao,'ListString',names_arq,'SelectionMode','multiple','Name','Dados analisados',...
            'ListSize',[300,280]); % "listdlg" cria uma caixa de diálogo com uma lista de opções para serem selecionadas e retorna os índices dessa lista

        % Armazenando cada bloco de arquivos em uma célula da matriz
        arquivos_cond{contador} = names_arq(indices_arq); % Cada elemento de "arquivos_cond" é uma célula

        % Atualizando o contador para o próximo loop            
        contador = contador + 1;
    end
end

% Verificando se nenhuma célula de "arquivs_cond" está vazia
if any(cellfun('isempty',arquivos_cond)) % "cellfun" aplica "isempty" em cada elemento da célula; "any" retorna verdadeiro se pelo menos 1 elemento estiver vazio
    error('O usuário não selecionou todos os arquivos de interesse. Reinicie a análise')
end

% Definindo as legendas das variáveis de acordo com a aplicação ou não da ETCC
if any(contains(names_arq,'HE')) || any(contains(names_arq,'HD')) % "contains" verifica se há "HD" ou "HE" nos nomes dos arquivos
    measures = {'Oxy_S_' 'Des_S_' 'Oxy_NS_' 'Des_NS_' 'Oxy_Both_' 'Des_Both_'}; % "any" retorna verdadeiro se houver "HD" ou "HE" em pelo menos 1 nome
else
    measures = {'Oxy_Left_' 'Des_Left_' 'Oxy_Right_' 'Des_Right_' 'Oxy_Both_' 'Des_Both_'};
end

clearvars list_arq names_arq instrucao indices_arq

%% Selecionando os dados da fNIRS de cada arquivo

% Agrupando horizontalmente os arquivos de cada combinação
all_arquivos = vertcat(arquivos_cond{:}); % "vertcat" concatena verticalmente os dados das células (nomes dos arquivos)

% Definindo o janelamento dos dados a ser agrupados
janelamento = questdlg('Você quer agrupar os dados de qual janelamento?',...
    'Definindo o janelamento','Total','Early','Late','Total'); % "questdlg" cria uma caixa de diálogo com uma pergunta e botões de resposta

% Inicializando uma célula vazia para armazenar os canais utilizados
channels = cell(numel(all_arquivos),1); % "numel" retorna o número de elementos da célula

% Inicializando uma célula vazia para armazenar os códigos dos participantes
all_codigos = cell(numel(all_arquivos),1);

% Inicializando uma matriz de células vazias para armazenar os dados de todos os arquivos e condições
all_data = cell(numel(all_arquivos),n_conds);

disp('Agrupando os dados da fNIRS dos seguintes arquivos:')

for narq = 1:length(all_arquivos)
    S = warning('OFF');

    % Abrindo o arquivo de interesse
    filename = all_arquivos{narq};
    load(filename);
    
    % Criando o nome do arquivo analisado
    underline_find = max(strfind(filename,'_')); % "strfind" retorna um vetor com as posições dos "_" em "filename"; "max" retorna a última ocorrência de "_" (última posição)
    name_arq = filename(1,1:underline_find-1); % "name_arq" será do 1º caractere de "filename" até o caractere antes do último "_"
    disp(['- ' name_arq])

    % Armazenando os códigos de cada participante
    all_codigos{narq} = name_arq;

    % Selecionando os canais analisados
    ch = num2str(fNIRS_Results.Channels); % "num2str" transforma números em strings
    channels{narq} = ch; % Armazenando os canais de cada arquivo na célula

    % Selecionando os dados do janelamento escolhido
    tabela_dados = table2array(fNIRS_Results.(janelamento)); % "table2array" transforma uma tabela em matriz (exclui as legendas)

    % Inicializando uma célula vazia para armazenar os dados de cada condição experimental do arquivo "narq"
    data_conds = cell(1,n_conds); 

    % Definindo índices para acessar os dados de cada condição experimental
    primeira_coluna = 1; 
    ultima_coluna = 6; % Cada condição possui 6 colunas no arquivo

    % Selecionando os dados de acordo com a quantidade de condições
    for i = 1:n_conds
        data = tabela_dados(:,primeira_coluna:ultima_coluna);

        % Distinguindo os dados em hemisfério esquerdo/direito ou estimulado/não estimulado
        if contains(filename,'HE','IgnoreCase',true) % Se houve ETCC no hemisfério esquerdo
            data_s = data(:,[1 3]); % "s" = estimulado
            data_ns = data(:,[2 4]); % "ns" = não estimulado
            data_oxy_des = [data_s data_ns];            
        elseif contains(filename,'HD','IgnoreCase',true) % Se houve ETCC no hemisfério direito
            data_s = data(:,[2 4]);
            data_ns = data(:,[1 3]);
            data_oxy_des = [data_s data_ns];
        else % Se não houve ETCC em um dos hemisférios
            data_left = data(:,[1 3]);
            data_right = data(:,[2 4]);
            data_oxy_des = [data_left data_right]; % Oxy-Left; Des-Left; Oxy-Right; Des-Right
        end

        % Selecionando os dados combinados (médias) entre os hemisférios        
        data_oxy_des_both_H = data(:,[5 6]);

        % Armazenando os dados de cada condição em um elemento da célula
        data_conds{i} = [data_oxy_des data_oxy_des_both_H]; 

        % Atualizando os indices para selecionar os dados da próxima condição
        primeira_coluna = primeira_coluna + 6;
        ultima_coluna = ultima_coluna + 6;
    end

    % Armazenando os dados de cada arquivo em uma célula da matriz
    for i = 1:n_conds
        all_data(narq,i) = data_conds(:,i); % Cada elemento de "all_data" é uma célula
    end
end

clearvars narq filename underline_find name_arq ch tabela_dados primeira_coluna ultima_coluna...
    data data_s data_ns data_left data_right data_oxy_des data_oxy_des_both_H data_conds

%% Combinando os nomes das condições experimentais e intervenções

% Inicializando uma célula vazia para armazenar as combinações
conditions = cell(n_conds*n_interventions,1);
contador = 1; % Servirá de índice para armazenar corretamente as combinações

for x = 1:n_conds
    condicao = names_conds{x};

    for y = 1:n_interventions
        intervention = names_interventions{y};

            % Armazenando cada combinação em um elemento da célula
            if isempty(intervention) % Se não houver intervenção, utiliza somente a condição experimental
                conditions{contador} = condicao;
            else
                conditions{contador} = [condicao '_' intervention];
            end

            % Atualizando o contador para o próximo loop
            contador = contador + 1;
    end
end

%% Agrupando todos os dados de acordo com cada condição-intervenção-momento

% Inicializando uma matriz de células vazias para armazenar os códigos dos participantes (nomes dos arquivos fNIRS analisados)
res_codigos = cell(numel(conditions),1);

% Inicializando uma matriz de células vazias para armazenar os dados de cada condição-intervenção-momento
res_data = cell(numel(conditions)*n_momentos,1);

% Descobrindo a quantidade de arquivos em cada célula de "arquivos_cond"
indices_arq = cellfun(@numel,arquivos_cond); % "cellfun" aplica a função "numel" em cada célula da matriz de células "arquivos_cond"

% Criando um vetor com a soma cumulativa dos elementos de "indices_arq"
indices_arq_acumulados = cumsum(indices_arq); % "cumsum" calcula a soma cumulativa dos elementos
contador = 1; % Servirá de índice para armazenar corretamente os dados e os códigos

for x = 1:n_conds
    first_line = 1;
    
    for y = 1:numel(indices_arq_acumulados)
        last_line = indices_arq_acumulados(y); % Linha que contém os dados do último arquivo do bloco intervenção-momento 
    
        if y > 1
            first_line = first_line + indices_arq(y-1);
        end

        % Armazenando os dados de cada condição-intervenção-momento em uma célula da matriz
        res_data{contador} = all_data(first_line:last_line,x); % Cada coluna de "all_data" contém os dados de uma condição

        % Armazenando os códigos de cada condição-intervenção-momento em uma célula da matriz
        res_codigos{contador} = all_codigos(first_line:last_line);

        % Atualizando o contador para o próximo loop
        contador = contador + 1;
    end    
end

% Organizando as matrizes "res" para separar os dados de cada momento em colunas distintas  
if n_momentos > 1

    res_data_temporario = {}; % Criando células vazias
    res_codigos_temporario = {};

    % Separando os dados e os códigos por momentos
    for i = 1:n_momentos
        res_data_temporario(:,i) = res_data(i:n_momentos:end);
        res_codigos_temporario(:,i) = res_codigos(i:n_momentos:end);
    end

    % Rearmazenando nas matrizes de células originais
    res_data = res_data_temporario;
    res_codigos = res_codigos_temporario;
end

clearvars -EXCEPT path_save all_arquivos janelamento channels measures n_momentos names_momentos conditions res_data res_codigos

%% Salvando os dados de cada condição e os canais utilizados

% Abrindo o diretório onde os dados serão salvos
cd(path_save)

% Salvando os canais analisados em formato ".txt"
res_channels = [all_arquivos channels];
writecell(res_channels,'fNIRS_Canais_Analisados','Delimiter','\t') % "writecell" salva dados de células em arquivo .txt

% Inicializando uma matriz de células vazias para armazenar os nomes das variáveis
res_outcomes = cell(numel(conditions),n_momentos); 

% Criando os nomes das variáveis
for w = 1:numel(conditions)
    cond = conditions{w};

    for x = 1:n_momentos
        momento = names_momentos{x};

        % Armazenando as legendas nas células
        if isempty(momento) % Se houver somente 1 momento de avaliação
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

    for z = 1:n_momentos % Cada aba da planilha irá conter os dados de um momento
        plan = names_momentos{z};
        outcomes = res_outcomes{x,z};
        ordem = res_codigos{x,z};
        dados = cell2mat(res_data{x,z}); % "cell2mat" transforma uma célula em matriz

        xlswrite(name_arq_excel,outcomes,plan,'A1') % "xlswrite" cria arquivo Excel
        xlswrite(name_arq_excel,ordem,plan,'A2')
        xlswrite(name_arq_excel,dados,plan,'B2')
    end
end

clear; clc
disp(char({'Acabou!! Os resultados da fNIRS foram agrupados.';'OBRIGADO PELA COLABORAÇÃO!'}))