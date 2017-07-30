% EM 알고리즘으로 최적의 혼합 가우시안 모델링 
% 환형 데이터 로딩하기 
load train1; 
% 초기 파라미터 설정 
[n D] = size(x);     % n : 관측 데이터 수, D : 차원
k = 6;               % 혼합수 
p = ones(1,k)/k;     % 혼합 비율 초기값
mu = randn(D,k);     % 평균 
s2 = zeros(D,D,k);   % 공분산 행렬
niter=100;           % 반복 횟수 
% 대각 성분상에서 지수적으로 독립한 분산값 초기화 
for i=1:k
  s2(:,:,i) = -100*diag(log(rand(D,1))); % variances
end

set(gcf,'Renderer','zbuffer');

clear Z;
try
  % niter 반복하여 EM 학습  
  for t=1:niter,
    fprintf('t=%d\r',t);
    % E-단계:
    for i=1:k
      Z(:,i) = p(i)*det(s2(:,:,i))^(-0.5)*exp(-0.5*sum((x'-repmat(mu(:,i),1,n))'*inv(s2(:,:,i)).*(x'-repmat(mu(:,i),1,n))',2));
    end
    Z = Z./repmat(sum(Z,2),1,k);
    
    % M-단계:
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
  disp('루프상에서 수치적 오류 발생 - 아마도 특이 행렬이 발생한 것 같음');
end;
