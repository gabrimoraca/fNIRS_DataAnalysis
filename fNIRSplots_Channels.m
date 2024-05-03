%% FUNÇÃO PARA PLOTAR OS DADOS DOS 8 CANAIS - 4 POR HEMISFÉRIO
% Desenvolvedor: Gabriel Antonio Gazziero Moraca
% Abril de 2024

function fNIRSplots_Channels(freq,name_arq,data_oxy,data_des,evento_min,path_channels)

% Criando o vetor de tempo em segundos
time = (1:length(data_oxy(evento_min:end,1)))./freq; % neste caso, "length" retorna o nº de linhas de "data_oxy"; "./" divide cada frame por "freq" para passar para segundos
time = time'; % ' Transpõe "time" para uma coluna (era uma linha)

% Definindo os títulos dos gráficos e os dados de interesse
for i = 1:2 % Serão criadas 2 figuras, uma para cada hemisfério
    if i == 1
        title_channels = {'Right PFC - ch1' 'Right PFC - ch2' 'Right PFC - ch3' 'Right PFC - ch4'};
        colunas = [1 2 3 4];
        side_channels = '_Right_Channels';
    else
        title_channels = {'Left PFC - ch5' 'Left PFC - ch6' 'Left PFC - ch7' 'Left PFC - ch8'};
        colunas = [5 6 7 8];
        side_channels = '_Left_Channels';
    end
    
    % Plotando os dados da Oxy e Desoxy de cada canal
    figure(i)
    fig = gcf;
    fig.WindowState = 'maximized'; % Maximiza a figura na tela
    set(gcf,'Name', [name_arq,' - Verifique os canais'])

    for x = 1:4
        subplot(4,1,x)
        plot(time,data_oxy(evento_min:end,colunas(x)),'r','LineWidth',2)
        hold on
        plot(time,data_des(evento_min:end,colunas(x)),'b','LineWidth',2)
        title(title_channels{x},'FontWeight','bold','FontSize',11)
        ylabel('µmol/L')
        grid off
        if x == 4 % Para colocar o nome do eixo x apenas no 4º subplot
            xlabel('Time (s)')
        end            
    end
        
    pause
    name_fig_channels = [path_channels,'\',name_arq,side_channels]; % Diretório com nome da figura
    saveas(gcf,[name_fig_channels,'.fig']); % Salvando no formato do matlab, para permitir edição posteriormente
    close
end

clearvars evento_min time title_channels colunas side_channels name_fig_channels
end