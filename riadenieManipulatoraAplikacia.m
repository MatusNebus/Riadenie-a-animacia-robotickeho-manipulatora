                    clc; close all; clear all;

% ========== VÝCHODISKOVÉ PARAMETRE ==========
global q1_last q2_last
q1_last = 0; q2_last = 0;
l1=0.25; l2=0.25; g=9.81; q1_zelane=0; q2_zelane=0;
% Spusti GUI
manipulatorApp();

% ========= GUI FUNKCIA =========
function manipulatorApp()
    global q1_last q2_last h ax
    fig = uifigure('Position', get(0, 'ScreenSize'));
    % fig = uifigure('Name','Riadenie manipulátora','Position',[100 100 800 600]);

    % ===== PID PARAMETRE =========
    uilabel(fig, 'Text','Parametre PID regulatorov:', 'Position',[20 680 200 22]);
    uilabel(fig, 'Text','P1:', 'Position',[20 660 30 22]);
    edt_P1 = uieditfield(fig, 'numeric', 'Position',[40 660 50 22], 'Value', 1000);
    uilabel(fig, 'Text','I1:', 'Position',[100 660 30 22]);
    edt_I1 = uieditfield(fig, 'numeric', 'Position',[120 660 50 22], 'Value', 100);
    uilabel(fig, 'Text','D1:', 'Position',[180 660 30 22]);
    edt_D1 = uieditfield(fig, 'numeric', 'Position',[200 660 50 22], 'Value', 300);

    uilabel(fig, 'Text','P2:', 'Position',[20 630 30 22]);
    edt_P2 = uieditfield(fig, 'numeric', 'Position',[40 630 50 22], 'Value', 1000);
    uilabel(fig, 'Text','I2:', 'Position',[100 630 30 22]);
    edt_I2 = uieditfield(fig, 'numeric', 'Position',[120 630 50 22], 'Value', 100);
    uilabel(fig, 'Text','D2:', 'Position',[180 630 30 22]);
    edt_D2 = uieditfield(fig, 'numeric', 'Position',[200 630 50 22], 'Value', 200);

    % ===== SATURÁCIE =========
    uilabel(fig, 'Text','Parametre blokov saturácie:', 'Position',[20 590 200 22]);
    uilabel(fig, 'Text','sat1 horny limit:', 'Position',[20 570 100 22]);
    edt_sat1up = uieditfield(fig, 'numeric', 'Position',[105 570 50 22], 'Value', 25);
    uilabel(fig, 'Text','sat1 dolny limit:', 'Position',[180 570 100 22]);
    edt_sat1low = uieditfield(fig, 'numeric', 'Position',[275 570 50 22], 'Value', -25);

    uilabel(fig, 'Text','sat2 horny limit:', 'Position',[20 540 100 22]);
    edt_sat2up = uieditfield(fig, 'numeric', 'Position',[105 540 50 22], 'Value', 15);
    uilabel(fig, 'Text','sat2 dolny limit:', 'Position',[180 540 100 22]);
    edt_sat2low = uieditfield(fig, 'numeric', 'Position',[275 540 50 22], 'Value', -15);
    
    % ===== TRENIE & HMOTNOSTI =========
    uilabel(fig, 'Text','Ďalšie nastavenia:', 'Position',[20 500 200 22]);
    uilabel(fig, 'Text','B1:', 'Position',[20 480 30 22]);
    edt_B1 = uieditfield(fig, 'numeric', 'Position',[40 480 50 22], 'Value', 2);
    uilabel(fig, 'Text','B2:', 'Position',[100 480 30 22]);
    edt_B2 = uieditfield(fig, 'numeric', 'Position',[120 480 50 22], 'Value', 2);

    uilabel(fig, 'Text','m1:', 'Position',[20 450 30 22]);
    edt_m1 = uieditfield(fig, 'numeric', 'Position',[40 450 50 22], 'Value', 3);
    uilabel(fig, 'Text','m2:', 'Position',[100 450 30 22]);
    edt_m2 = uieditfield(fig, 'numeric', 'Position',[120 450 50 22], 'Value', 3);

    uilabel(fig, 'Text','Čas trvania simulácie:', 'Position',[20 420 150 22]);
    edt_stoptime = uieditfield(fig, 'numeric', 'Position',[150 420 50 22], 'Value', 4);

    % ===== VSTUPY: Uhly =========
    uilabel(fig, 'Text','ŽELANÉ UHLY:', 'Position',[90 380 150 22]);
    uilabel(fig, 'Text','q1:', 'Position',[70 360 30 22]);
    edt_q1 = uieditfield(fig, 'numeric', 'Position',[90 360 50 22], 'Value', 45);
    uilabel(fig, 'Text','q2:', 'Position',[150 360 30 22]);
    edt_q2 = uieditfield(fig, 'numeric', 'Position',[170 360 50 22], 'Value', 0);

    % ===== STAVOVÝ TEXT =========
    uilabel(fig, 'Position',[40 330 400 22], ...
        'Text','(Nové hodnoty zadávajte až po skonční animácie.)', ...
        'FontColor','[0.5 0.5 0.5]');
    statusLabel = uilabel(fig, ...
        'Position',[40 300 400 22], ...
        'Text','', ...
        'FontColor','[0 0.5 0]', ...
        'FontWeight','bold');
    setappdata(fig, 'statusLabel', statusLabel);

    % ===== TLAČIDLO =========
    uibutton(fig, 'Position',[50 250 200 30], 'Text','SPUSTIŤ ANIMÁCIU', ...
        'ButtonPushedFcn', @(btn,event) spustiSimulaciu(fig, ...
            edt_q1.Value, edt_q2.Value, ...
            edt_P1.Value, edt_I1.Value, edt_D1.Value, ...
            edt_P2.Value, edt_I2.Value, edt_D2.Value, ...
            edt_sat1up.Value, edt_sat1low.Value, ...
            edt_sat2up.Value, edt_sat2low.Value, ...
            edt_B1.Value, edt_B2.Value, ...
            edt_m1.Value, edt_m2.Value, edt_stoptime.Value));

    % ===== OBRAZOVKA MANIPULÁTORA =========
    ax = uiaxes(fig, 'Position', [350 350 350 350]);
    axis(ax, 'equal'); xlim(ax, [-0.53 0.53]); ylim(ax, [-0.53 0.53]);
    grid(ax, 'on'); title(ax, 'Animácia manipulátora');

    %vykreslenie manipulatora
    [x1, y1, x2, y2] = pocitajPolohu(0, 0);
    hold(ax, 'on');
    h1 = plot(ax, [0, x1], [0, y1], 'Color', [1, 0.5, 0], 'LineWidth', 5);
    h2 = plot(ax, [x1, x2], [y1, y2], 'Color', [1, 0.75, 0], 'LineWidth', 3);
    p0 = plot(ax, 0, 0, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
    p1 = plot(ax, x1, y1, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', [0.5, 0.25, 0]);
    p2 = plot(ax, x2, y2, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'r');
    h = [h1, h2, p0, p1, p2];

    % ===== GRAFY q1,q2,T1,T2 =========
    ax_q1 = uiaxes(fig, 'Position', [720 500 300 200]);
    title(ax_q1, 'Priebeh q1 [rad]');
    xlabel(ax_q1, 't [s]');
    ylabel(ax_q1, 'q1 [rad]');
    grid(ax_q1, 'on');
    setappdata(fig, 'ax_q1', ax_q1);

    ax_q2 = uiaxes(fig, 'Position', [720 300 300 200]);
    title(ax_q2, 'Priebeh q2 [rad]');
    xlabel(ax_q2, 'čas [s]');
    ylabel(ax_q2, 'q2');
    grid(ax_q2, 'on');
    setappdata(fig, 'ax_q2', ax_q2);

    ax_T1 = uiaxes(fig, 'Position', [320 100 300 200]);
    title(ax_T1, 'Priebeh T1 [Nm]');
    xlabel(ax_T1, 'čas [s]');
    ylabel(ax_T1, 'T1');
    grid(ax_T1, 'on');
    setappdata(fig, 'ax_T1', ax_T1);

    ax_T2 = uiaxes(fig, 'Position', [620 100 300 200]);
    title(ax_T2, 'Priebeh T2 [Nm]');
    xlabel(ax_T2, 'čas [s]');
    ylabel(ax_T2, 'T2');
    grid(ax_T2, 'on');
    setappdata(fig, 'ax_T2', ax_T2);
end

% ========= SIMULÁCIA =========
function spustiSimulaciu(fig, q1_deg, q2_deg, P1, I1, D1, P2, I2, D2, ...
                         sat1up, sat1low, sat2up, sat2low, ...
                         B1, B2, m1, m2, stoptime)
    global q1_last q2_last

    q1 = deg2rad(q1_deg);  q2 = deg2rad(q2_deg);

    % Nastavenie do Simulinku
    assignin('base','P1',P1); assignin('base','I1',I1); assignin('base','D1',D1);
    assignin('base','P2',P2); assignin('base','I2',I2); assignin('base','D2',D2);
    assignin('base','sat1up',sat1up); assignin('base','sat1low',sat1low);
    assignin('base','sat2up',sat2up); assignin('base','sat2low',sat2low);
    assignin('base','B1',B1); assignin('base','B2',B2);
    assignin('base','m1',m1); assignin('base','m2',m2);
    assignin('base','q1_init',q1_last); assignin('base','q2_init',q2_last);
    set_param('zad2_sim/q1_zelane', 'Value', num2str(q1));
    set_param('zad2_sim/q2_zelane', 'Value', num2str(q2));

    set(getappdata(fig, 'statusLabel'), 'Text', '');

    try
        simOut = sim('zad2_sim.slx','StopTime',num2str(stoptime));
        q1_sim = simOut.get('q1_out'); q1_sim = q1_sim(:);
        q2_sim = simOut.get('q2_out'); q2_sim = q2_sim(:);
        T1_sim = simOut.get('T1_out'); T1_sim = T1_sim(:);
        T2_sim = simOut.get('T2_out'); T2_sim = T2_sim(:);

        %vykreslenie q1 do grafu:
        ax_q1 = getappdata(fig, 'ax_q1');
        cla(ax_q1);
        t = linspace(0, stoptime, length(q1_sim));
        plot(ax_q1, t, q1_sim, 'LineWidth', 1.5, 'Color', [0.5, 0.25, 0]);
        
        %vykreslenie q2 do grafu:
        ax_q2 = getappdata(fig, 'ax_q2');
        cla(ax_q2);
        t = linspace(0, stoptime, length(q2_sim));
        plot(ax_q2, t, q2_sim, 'LineWidth', 1.5, 'Color', 'r');

        %vykreslenie T1
        ax_T1 = getappdata(fig, 'ax_T1');
        cla(ax_T1);
        plot(ax_T1, t, T1_sim, 'LineWidth', 1.5, 'Color', 'k');

        %vykreslenie T2
        ax_T2 = getappdata(fig, 'ax_T2');
        cla(ax_T2);
        plot(ax_T2, t, T2_sim, 'LineWidth', 1.5, 'Color', 'k');

        animujManipulator(q1_sim, q2_sim, fig);
        q1_last = q1_sim(end); q2_last = q2_sim(end);

        set(getappdata(fig, 'statusLabel'), 'Text', 'Hotovo, môžete zadať nové hodnoty.');

    catch ME
        uialert(fig, "Chyba pri simulácii:\n" + ME.message, 'Chyba');
    end
end

% ========= ANIMÁCIA =========
function animujManipulator(q1_vec, q2_vec, fig)
    global q1_last q2_last h ax
    q1_vec = [q1_last; q1_vec];
    q2_vec = [q2_last; q2_vec];
    l1 = 0.25; l2 = 0.25;
    for i = 1:length(q1_vec)
        q1 = q1_vec(i); q2 = q2_vec(i);
        [x1, y1, x2, y2] = pocitajPolohu(q1, q2);
        set(h(1), 'XData', [0, x1], 'YData', [0, y1]);
        set(h(2), 'XData', [x1, x2], 'YData', [y1, y2]);
        set(h(3), 'XData', 0, 'YData', 0);
        set(h(4), 'XData', x1, 'YData', y1);
        set(h(5), 'XData', x2, 'YData', y2);
        drawnow;
        % pause(0.001);
    end
end

%========= KINEMATIKA =========
function [x1, y1, x2, y2] = pocitajPolohu(q1, q2)
    l1 = 0.25; l2 = 0.25;
    x1 = l1 * cos(q1); y1 = l1 * sin(q1);
    x2 = x1 + l2 * cos(q1 + q2); y2 = y1 + l2 * sin(q1 + q2);
end
