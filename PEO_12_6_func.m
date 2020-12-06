function [Gbest,Fit_min,fit_PEO]= PEO_12_6_func(fhd,Dimension,Particle_Number,Max_Gen,VRmin,VRmax,varargin)
% fhd=str2func('cec14_func'); Fnum = 30;

% func_num =30;

% Max_Gen = Max_Gen;
Np = Particle_Number;
Lb = VRmin;
Ub = VRmax;
Dim = Dimension;

sigma = 0.1*(Ub-Lb);    % Mutation Range (Standard Deviation)
TT = sigma;
% ��ʼ��k�����Ž�
K = floor(log(Np))+1;
L_pha = zeros(K,Dim);
L_Pha_fit = zeros(1,K);


% ��ʼ������x
Pha=initialization(Np,Dim,Ub,Lb);
% ����fitness
fitness = feval(fhd,Pha',varargin{:});
% k�����Ž⸳ֵ
[~,f_index] = sort(fitness);
% ��ʼ��ȫ������
Fit_min = fitness(f_index(1)); % ȫ������ֵ
Gbest = Pha(f_index(1),:);
% ��ʼ��K���ֲ�����
for i = 1:K
    L_pha(i,:) = Pha(f_index(i),:);
    L_Pha_fit(i) =  fitness(f_index(i));
end
% ��ʼ��������Ⱥ����
A = zeros(Np,Dim);
% ��ʼ����Ⱥ����x 
Px= (1/Np)*ones(1,Np);
% ��ʼ����Ⱥ������
Pa = 1.1*ones(1,Np);

count = 1;
fit_PEO(count) = Fit_min;
% pic_num = 1;
for t = 2:Max_Gen
    count = count + 1;
    % �����µ�λ��
    new_Pha = Pha + A;
    %�߽�Լ��
    new_Pha=space_bound(new_Pha,Ub,Lb);
    
    % �������е�fitness
    new_fitness = feval(fhd,new_Pha',varargin{:});
    % ������Сֵ�����ֵ����������Ӧ������
    new_fit_best = min(new_fitness); new_fit_worst = max(new_fitness);
    % ����ȫ������
    [~,new_f_index] = sort(new_fitness);
    if new_fitness(new_f_index(1)) <= Fit_min
        Fit_min = new_fitness(new_f_index(1));
        Gbest = new_Pha(new_f_index(1),:);
    end
    % ���¾ֲ�����
    for j = 1:K
        if new_fitness(new_f_index(j))<= L_Pha_fit(j)
            L_Pha_fit(j) = new_fitness(new_f_index(j));
            L_pha(j,:) = new_Pha(new_f_index(j),:);
        end
    end
    % ���½��λ��
    for p = 1:Np
        % λ���Ƿ����
        if new_fitness(p) <= fitness(p)
            % λ�ø���
            Pha(p,:) = new_Pha(p,:);
            fitness(p) = new_fitness(p);
            % ���·�ֳ����
            %�����µ���Ⱥ����
            Px(p) = Pa(p)*Px(p)*(1-Px(p));
            %�����µ���Ⱥ�ݻ�����
            A1 = choosebest(L_pha,Pha(p,:)); % ��ͬ�������������
            A1=A1.*0.2;
            A3 = tubian(Dim,sigma);
            A(p,:) =  (1-Px(p)).*A1+ Px(p).*(A(p,:) + A3);
        else
            if rand <= (Px(p))
                Pha(p,:) = new_Pha(p,:);
                fitness(p) = new_fitness(p);
                %�����µ���Ⱥ����
                Px(p) = Pa(p)*Px(p)*(1-Px(p));
            end
            A1 = choosebest(L_pha,Pha(p,:)); % ��ͬ�������������
            % ��������������������������֮ǰ������ʽ ���û����������ھֲ������ƶ�
            A(p,:) = rand(1,Dim).*A1+TT.*randn(1,Dim); % ���������
            TT = TT*0.99;
        end
        
        %������Ⱥ��ľ����빲��
        % ��ǰ��Ⱥ�����ѡ��һ����Ⱥ���Ƿ��������������ͻ��������
        % ���㵱ǰ��Ⱥ���������� �ж����������Ƿ񽻲�
        temp_hab = sigma; % �������޸�
        % ���ѡ��һ�� % ���ѡһ��������
        temp = randperm(Np);
        if temp(1) ~=p, tp = temp(1);
        else 
            tp = temp(2);
        end
        % �Ƿ����־���
        if dist(Pha(p,:),Pha(tp,:)') < temp_hab*((Max_Gen+1-t)/Max_Gen)
            % ���־���
            % ������������
            d_p = Pa(p)*Px(p)*(1-Px(p)-(fitness(tp)/fitness(p))*Px(tp));
%             d_tp = Pa(tp)*Px(tp)*(1-Px(tp)-(fitness(p)/fitness(tp))*Px(p));
            Px(p) = Px(p) + d_p;
            % ��������������
            A(p,:) = A(p,:) + ((fitness(tp)-fitness(p))/fitness(tp)).*(Pha(tp,:)-Pha(p,:));
            
        end

        
        % Լ��a��ȡֵ
        if Pa(p) <=0.1 || Pa(p) >=4 || Px(p) <=0.001
            % ���������
            Px(p) = (1/Np);
            Pa(p) = 1.1;
            Pha(p,:) = Lb.*ones(1,Dim) + (Ub-Lb).*ones(1,Dim).*rand(1,Dim);
            A(p,:) = zeros(1,Dim);
            fitness(p) = Inf;
        end
    end
    fit_PEO(count) = Fit_min;
    % �����µ�����

end     
%       Fit_min      
end
function A3 = tubian(Dim,sigma)
S = floor(rand/(1/Dim));
A3 = zeros(1,Dim);
if S >=1 && S<=Dim
    J = randperm(Dim,S);
    A3(J) = 1;
    A3 = A3.*2.*sigma.*randn(1,Dim);
%     A3 = (S/Dim).*A3;
end

end

function A1 = choosebest(L_pha,newpha)
% ѡ�����Լ�����ľֲ�����
[K, dim] = size(L_pha);
temp_dsit = zeros(1,K);
for i = 1:K
    temp_dsit(i) = dist(L_pha(i,:),newpha');
end
[~,index]=min(temp_dsit);
% ��һ�� ֱ��ȫ��άѡȡ
A1 = (L_pha(index,:)- newpha);
% �ڶ��� 
end
% This function initialize the first population of search agents
function Positions=initialization(SearchAgents_no,dim,ub,lb)

Boundary_no= size(ub,2); % numnber of boundaries

% If the boundaries of all variables are equal and user enter a signle
% number for both ub and lb
if Boundary_no==1
    Positions=rand(SearchAgents_no,dim).*(ub-lb)+lb;
end

% If each variable has a different lb and ub
if Boundary_no>1
    for i=1:dim
        ub_i=ub(i);
        lb_i=lb(i);
        Positions(:,i)=rand(SearchAgents_no,1).*(ub_i-lb_i)+lb_i;
    end
end
end
%This function checks the search space boundaries for agents.
function  X=space_bound(X,up,low)

[N,dim]=size(X);
for i=1:N 
%     %%Agents that go out of the search space, are reinitialized randomly .
    Tp=X(i,:)>up;Tm=X(i,:)<low;X(i,:)=(X(i,:).*(~(Tp+Tm)))+((rand(1,dim).*(up-low)+low).*(Tp+Tm));
%     %%Agents that go out of the search space, are returned to the boundaries.
%         Tp=X(i,:)>up;Tm=X(i,:)<low;X(i,:)=(X(i,:).*(~(Tp+Tm)))+up.*Tp+low.*Tm;

end
end
