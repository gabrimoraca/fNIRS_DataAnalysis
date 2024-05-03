%% FUNÇÃO PARA PLOTAR OS DADOS DE CADA CONDIÇÃO EXPERIMENTAL
% Desenvolvedor: Gabriel Antonio Gazziero Moraca
% Abril de 2024

function fNIRSplots_ConditionsData(freq,name_arq,name_cond_atual,path_figure,mean_epoch_all,std_epoch_all)

% Criando o vetor de tempo em segundos
time_epoch = (1:length(mean_epoch_all))./freq; % neste caso, "length" retorna o nº de linhas de "mean_epoch_all"; "./" divide cada frame por "freq" para passar para segundos
time_epoch = time_epoch'; % ' Transpõe para tornar "time_epoch" uma coluna

% Inicializando matrizes vazias para armazenar a dispersão dos dados
[~,n_colunas] = size(std_epoch_all); % "size" retorna um vetor com o nº de linhas (parâmetro 1) e de colunas (parâmetro 2); "~" usado para não retornar o nº de linhas
std_positive = zeros(length(std_epoch_all),n_colunas);
std_negative = zeros(length(std_epoch_all),n_colunas);

% Calculando a dispersão dos dados
for i = 1:n_colunas
    media = mean_epoch_all(:,i);
    std = std_epoch_all(:,i);
    std_positive(:,i) = media + std;
    std_negative(:,i) = media - std;
end

% Criando os títulos de cada gráfico
subplot_titles = {'Left PFC Oxy - ' 'Right PFC Oxy - ' 'Left PFC Desoxy - ' 'Right PFC Desoxy - ' 'Combined PFC Oxy - ' 'Combined PFC Desoxy - '};

% Plotando os dados da Oxy e Desoxy de cada hemisfério
figure(3);
fig = gcf;
fig.WindowState = 'maximized'; % Maximiza a figura na tela
set(gcf,'Name', [name_arq,' - ',name_cond_atual])

for i = 1:4
    if i == 1 || i == 2
        cor = 'r'; % Oxy em vermelho
    else
        cor = 'b'; % Desoxy em azul
    end

    subplot(2,2,i) % 4 subplots: Oxy left e right; Desoxy left e right
    plot(time_epoch,mean_epoch_all(:,i),cor,'LineWidth',2)
    hold on
    plot(time_epoch,std_positive(:,i),cor,'LineWidth',0.5)
    plot(time_epoch,std_negative(:,i),cor,'LineWidth',0.5)
    title([subplot_titles{i},name_cond_atual],'FontWeight','bold','FontSize',14)
    xlabel('Time (s)')
    ylabel('µmol/L')
    xlim([0 max(time_epoch)])
    ylim([-2 3])
    yL = get(gca,'YLim');
    line([20 20],yL,'LineStyle','--','Color','k','LineWidth', 1)
    xL = xlim();
    plot(xL,[0, 0],'LineStyle',':','Color','k')
    xt = 9;
    yt = 2.5;
    txt1 = 'Baseline';
    text(xt,yt,txt1);
    xt2 = 33;
    txt2 = 'Tarefa';
    text(xt2,yt,txt2);
end  

pause
name_figure_cond_atual = [path_figure,'\',name_arq,'_',name_cond_atual,'_H_Separated']; % Diretório com nome da figura
saveas(gcf,[name_figure_cond_atual,'.fig']); % Salvando no formato do matlab, para permitir edição posteriormente
close

% Plotando os dados da Oxy e Desoxy dos hemisférios combinados (média)
figure(4);
fig = gcf;
fig.WindowState = 'maximized';
set(gcf,'Name', [name_arq,' - ',name_cond_atual,' - Hemisférios combinados'])

for i = 1:2
    if i == 1
        cor = 'r';
        ii = 5;
    else
        cor = 'b';
        ii = 6;
    end

    subplot(2,2,i) % Serão 2 subplots, mas deixei 2 linhas em branco para os gráficos não ficarem distorcidos verticalmente
    plot(time_epoch,mean_epoch_all(:,ii),cor,'LineWidth',2)
    hold on
    plot(time_epoch,std_positive(:,ii),cor,'LineWidth',0.5)
    plot(time_epoch,std_negative(:,ii),cor,'LineWidth',0.5)
    title([subplot_titles{ii},name_cond_atual],'FontWeight','bold','FontSize',14)
    xlabel('Time (s)')
    ylabel('µmol/L')
    xlim([0 max(time_epoch)])
    ylim([-2 3])
    yL = get(gca,'YLim');
    line([20 20],yL,'LineStyle','--','Color','k','LineWidth', 1)
    xL = xlim();
    plot(xL,[0, 0],'LineStyle',':','Color','k')
    xt = 9;
    yt = 2.5;
    txt1 = 'Baseline';
    text(xt,yt,txt1);
    xt2 = 33;
    txt2 = 'Tarefa';
    text(xt2,yt,txt2);
end               

pause
name_figure_cond_atual = [path_figure,'\',name_arq,'_',name_cond_atual,'_H_Combined'];
saveas(gcf,[name_figure_cond_atual,'.fig']);
close

clearvars time_epoch n_colunas std_positive std_negative media std subplot_titles name_figure_cond_atual

end