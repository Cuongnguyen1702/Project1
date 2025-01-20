%Le Tran Khanh An - 22207001
%Vu Viet Hoang - 22207031
%Mai Xuan Khang - 22207043
%Nguyen Cong Cuong - 22207125
clc;clear;
%1.Load a speech file with sample rate 𝐹𝑠 = 4000.
Fs = 4000;
[mSpeech, Fs] = audioread("MaleSpeech-16-4-mono-20secs.wav");

t = 0:1/Fs:1.5;
mSpeech = mSpeech*10;%Amplifying signal
plot(t, mSpeech(1:length(t)), 'LineWidth', 2, 'DisplayName','Sample signal');
grid;
hold on;
%2.Quantize the sample signal ‘mSpeech’ with 𝐿 = 16, 𝑞 = 𝑉_𝑝/(𝐿 − 1), called 𝑠𝑞2 signal.
L = 16; 
V_p = 0.5625;
q = (V_p-(-V_p))/(L - 1);
s_q_2 = quan_uni(mSpeech(1:length(t)), q);
%3.Plot ‘mSpeech‘ and 𝑠𝑞2.
plot(t, s_q_2(1:length(t)),'ro', 'MarkerSize', 6, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r','DisplayName','Uniform quantized values');
hold on;
%4.Calculate the quantizer error variance (𝜎𝑠𝑞2)^2 and the ratio of average signal power to average quantization noise power (𝑆/𝑁)𝑠𝑞2 by the numerical method.
%Quantizer error variance(numerical method)
variance_sq_2 = quantizer_error_variance(s_q_2, q)
%(S/N)sq2(numerical method)
SNR_sq2 = SNR_quant(mSpeech, s_q_2, t)

% 5. Compress the sample signal ‘mSpeech’
mu = 255; % μ-law compression constant
s_c_5 = sign(mSpeech(1:length(t))) .* (log(1 + mu * abs(mSpeech(1:length(t))) / V_p) ./ log(1 + mu)); % μ-law compression

% Plot the compressed signal
%figure;
plot(t, s_c_5, 'yellow--', 'LineWidth', 2, 'DisplayName', 'Compressed signal (μ-law)');
hold on;

% 6. Quantize the compressed signal
s_q_6 = quan_uni(s_c_5, q); % Uniform quantization of compressed signal
plot(t, s_q_6, 'g^', 'MarkerSize', 6, 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g', 'DisplayName','Quantized compressed signal');
hold on;
% Add legend and labels
legend;
xlabel('Time (s)');
ylabel('Amplitude');
title('Compression and Quantization');
grid on;

%quan_uni function
function quan_sig = quan_uni(signal, q)
    for i=1:length(signal)
        quan_sig(i) = quant(signal(i), q);
        d = signal(i) - quan_sig(i);
        if d == 0   
            quan_sig(i) = quan_sig(i) + q/2;
        elseif (d > 0) && (abs(d) < q/2)
            quan_sig(i) = quan_sig(i) + q/2;
        elseif (d > 0) && (abs(d) >= q/2)
            quan_sig(i) = quan_sig(i) - q/2;
        elseif (d < 0) && (abs(d) < q/2)
            quan_sig(i) = quan_sig(i) - q/2;
        elseif (d < 0) && (abs(d) >= q/2)
            quan_sig(i) = quan_sig(i) + q/2;
        end
    end
end
%quantizer_error_variance function
function quant_err_variance = quantizer_error_variance(signal, q)
    p_e = 1/q;
    b = q/2;
    a = -q/2;
    N = length(signal);
    h = (b-a)/N;
    fe = 'e^2';
    fei = str2func(['@(e)', fe]);
    sumile = 0;
    sumichan = 0;
    for i=1:2:N-1
        sumile = sumile + fei(a+i*h);
    end
    for i=2:2:N-1
        sumichan = sumichan + fei(a+i*h);
    end
    quant_err_variance = p_e*((h/3)*(fei(a)+fei(b)+4*sumile+2*sumichan));
end

function SNR_result = SNR_quant(original, signal, t)
    e_uni = original(1:length(t))-signal;
    pow_noise_uni = 0;
    pow_sig = 0;
    for i=1:length(t)
        pow_sig = pow_sig + original(i)^2;
        pow_noise_uni = pow_noise_uni + e_uni(i)^2;
    end
    SNR_result = pow_sig/pow_noise_uni;
end