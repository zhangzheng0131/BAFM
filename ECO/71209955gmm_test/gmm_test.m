% EM �˰������� ������ ȥ�� ����þ� �𵨸� 
% ȯ�� ������ �ε��ϱ� 
load train1; 
% �ʱ� �Ķ���� ���� 
[n D] = size(x);     % n : ���� ������ ��, D : ����
k = 6;               % ȥ�ռ� 
p = ones(1,k)/k;     % ȥ�� ���� �ʱⰪ
mu = randn(D,k);     % ��� 
s2 = zeros(D,D,k);   % ���л� ���
niter=100;           % �ݺ� Ƚ�� 
% �밢 ���л󿡼� ���������� ������ �л갪 �ʱ�ȭ 
for i=1:k
  s2(:,:,i) = -100*diag(log(rand(D,1))); % variances
end

set(gcf,'Renderer','zbuffer');

clear Z;
try
  % niter �ݺ��Ͽ� EM �н�  
  for t=1:niter,
    fprintf('t=%d\r',t);
    % E-�ܰ�:
    for i=1:k
      Z(:,i) = p(i)*det(s2(:,:,i))^(-0.5)*exp(-0.5*sum((x'-repmat(mu(:,i),1,n))'*inv(s2(:,:,i)).*(x'-repmat(mu(:,i),1,n))',2));
    end
    Z = Z./repmat(sum(Z,2),1,k);
    
    % M-�ܰ�:
    for i=1:k
      mu(:,i) = (x'*Z(:,i))./sum(Z(:,i));
      s2(:,:,i) = (x'-repmat(mu(:,i),1,n))*(repmat(Z(:,i),1,D).*(x'-repmat(mu(:,i),1,n))')./sum(Z(:,i));
      p(i) = mean(Z(:,i));
    end
    
    clf
    hold on
    plot3(x(:,1),x(:,2),x(:,3),'.');
    for i=1:k
      plot_gaussian(s2(:,:,i),mu(:,i),i,20);
    end
    drawnow;
  end
catch
  disp('�����󿡼� ��ġ�� ���� �߻� - �Ƹ��� Ư�� ����� �߻��� �� ����');
end;
