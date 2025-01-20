%Le Tran Khanh An - 22207001
%Vu Viet Hoang - 22207031
%Mai Xuan Khang - 22207043
%Nguyen Cong Cuong - 22207125
clc;clear;
%1.Load a speech file with sample rate 𝐹𝑠 = 4000.
Fs = 4000;
[mSpeech, Fs] = audioread("MaleSpeech-16-4-mono-20secs.wav");

t = 0:1/Fs:1.5;
plot(t, mSpeech(1:length(t)), 'LineWidth', 2, 'DisplayName','Sample signal');
grid;
hold on;
%2.Quantize the sample signal ‘mSpeech’ with 𝐿 = 16, 𝑞 = 𝑉_𝑝/(𝐿 − 1), called 𝑠𝑞2 signal.
L = 16; 
V_p = 0.5625;
q = V_p/(L - 1);
s_q_2 = quan_uni(mSpeech(1:length(t)), q);
%3.Plot ‘mSpeech‘ and 𝑠𝑞2.
plot(t, s_q_2(1:length(t)),'ro', 'MarkerSize', 6, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r','DisplayName','Uniform quantized values');
legend
%4.Calculate the quantizer error variance (𝜎𝑠𝑞2)^2 and the ratio of average signal power to average quantization noise power (𝑆/𝑁)𝑠𝑞2 by the numerical method.
%Quantizer error variance(numerical method)
p_e = 1/q;
b = q/2;
a = -q/2;
N = length(s_q_2);
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
quantizer_err_variance = p_e*((h/3)*(fei(a)+fei(b)+4*sumile+2*sumichan))
%(S/N)sq2(numerical method)
e_uni = mSpeech(1:length(t))-s_q_2;
pow_noise_uni = 0;
pow_sig = 0;
for i=1:length(t)
    pow_noise_uni = pow_noise_uni + e_uni(i)^2;
    pow_sig = pow_sig + mSpeech(i)^2;
end
SNR_uni = pow_sig/pow_noise_uni

function y = quan_uni(signal, step)
    y = step*round(signal/step + 0.5);
end