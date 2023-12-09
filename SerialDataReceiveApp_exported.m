classdef SerialDataReceiveApp_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure             matlab.ui.Figure
        ButtonGroup          matlab.ui.container.ButtonGroup
        jointAngleMode       matlab.ui.control.RadioButton
        directedVoltageMode  matlab.ui.control.RadioButton
        default              matlab.ui.control.RadioButton
        ArduinomsLabel_3     matlab.ui.control.Label
        ArduinomsLabel_2     matlab.ui.control.Label
        time_switching       matlab.ui.control.NumericEditField
        time_approval        matlab.ui.control.NumericEditField
        SWITCHButton         matlab.ui.control.Button
        STOPButton           matlab.ui.control.Button
        WRITEButton          matlab.ui.control.Button
        Label_16             matlab.ui.control.Label
        Panel_8              matlab.ui.container.Panel
        Label_22             matlab.ui.control.Label
        error_3              matlab.ui.control.NumericEditField
        FFgain_3             matlab.ui.control.EditField
        KffLabel_3           matlab.ui.control.Label
        Igain_3              matlab.ui.control.EditField
        KiLabel_5            matlab.ui.control.Label
        Dgain_3              matlab.ui.control.EditField
        KdLabel_4            matlab.ui.control.Label
        Pgain_3              matlab.ui.control.EditField
        KpLabel_4            matlab.ui.control.Label
        Button_11            matlab.ui.control.Button
        Button_9             matlab.ui.control.Button
        MDpwm_3              matlab.ui.control.NumericEditField
        dsum_3               matlab.ui.control.NumericEditField
        deri_3               matlab.ui.control.NumericEditField
        diff_3               matlab.ui.control.NumericEditField
        angle_3              matlab.ui.control.NumericEditField
        targetangle_3        matlab.ui.control.NumericEditField
        dsumLabel_3          matlab.ui.control.Label
        deriLabel_3          matlab.ui.control.Label
        diffLabel_3          matlab.ui.control.Label
        PWMLabel_3           matlab.ui.control.Label
        Label_19             matlab.ui.control.Label
        tgtLabel_4           matlab.ui.control.Label
        TimeGraph_3          matlab.ui.control.UIAxes
        Panel_7              matlab.ui.container.Panel
        Label_20             matlab.ui.control.Label
        error_1              matlab.ui.control.NumericEditField
        Button_3             matlab.ui.control.Button
        Button_2             matlab.ui.control.Button
        FFgain_1             matlab.ui.control.EditField
        KffLabel             matlab.ui.control.Label
        Igain_1              matlab.ui.control.EditField
        KiLabel_3            matlab.ui.control.Label
        Dgain_1              matlab.ui.control.EditField
        KdLabel_2            matlab.ui.control.Label
        Pgain_1              matlab.ui.control.EditField
        KpLabel_2            matlab.ui.control.Label
        dsumLabel            matlab.ui.control.Label
        dsum_1               matlab.ui.control.NumericEditField
        deriLabel            matlab.ui.control.Label
        deri_1               matlab.ui.control.NumericEditField
        diffLabel            matlab.ui.control.Label
        diff_1               matlab.ui.control.NumericEditField
        MDpwm_1              matlab.ui.control.NumericEditField
        PWMLabel             matlab.ui.control.Label
        angle_1              matlab.ui.control.NumericEditField
        targetangle_1        matlab.ui.control.NumericEditField
        Label_17             matlab.ui.control.Label
        tgtLabel             matlab.ui.control.Label
        Label_14             matlab.ui.control.Label
        TimeGraph_1          matlab.ui.control.UIAxes
        Panel_6              matlab.ui.container.Panel
        Label_21             matlab.ui.control.Label
        error_2              matlab.ui.control.NumericEditField
        Button_10            matlab.ui.control.Button
        Button_8             matlab.ui.control.Button
        FFgain_2             matlab.ui.control.EditField
        KffLabel_2           matlab.ui.control.Label
        Igain_2              matlab.ui.control.EditField
        KiLabel_4            matlab.ui.control.Label
        Dgain_2              matlab.ui.control.EditField
        KdLabel_3            matlab.ui.control.Label
        Pgain_2              matlab.ui.control.EditField
        KpLabel_3            matlab.ui.control.Label
        dsum_2               matlab.ui.control.NumericEditField
        deri_2               matlab.ui.control.NumericEditField
        diff_2               matlab.ui.control.NumericEditField
        MDpwm_2              matlab.ui.control.NumericEditField
        angle_2              matlab.ui.control.NumericEditField
        targetangle_2        matlab.ui.control.NumericEditField
        dsumLabel_2          matlab.ui.control.Label
        deriLabel_2          matlab.ui.control.Label
        diffLabel_2          matlab.ui.control.Label
        PWMLabel_2           matlab.ui.control.Label
        Label_18             matlab.ui.control.Label
        tgtLabel_3           matlab.ui.control.Label
        Label_15             matlab.ui.control.Label
        TimeGraph_2          matlab.ui.control.UIAxes
        CONTROLButton        matlab.ui.control.Button
        MatlabPeriod         matlab.ui.control.NumericEditField
        MatlabmsLabel        matlab.ui.control.Label
        ArduinoPeriod        matlab.ui.control.NumericEditField
        ArduinomsLabel       matlab.ui.control.Label
        OPENButton           matlab.ui.control.Button
        PositionGraph        matlab.ui.control.UIAxes
    end


    properties (Access = private)
        DRAW_INTERVAL_OF_TIME_GRAPH = 1;
        DRAW_INTERVAL_OF_POS_GRAPH = 10;
        plot_count = 1;

        %角度情報を格納する行列(各関節の現在角度、目標角度)
        Matrix_AngleData = NaN(20000, 6);
        %MDに入る指令電圧を格納する行列
        Matrix_PWMData = NaN(20000, 3);

        %plotの横列表示用列ベクトル
        vector_timeax = 1:20000;
        vector_timeax_of_drawgraph = 1:4000;

        %スクロール用の変数　グラフ幅4000でscroll_timeWidthを過ぎたらスクロール開始
        TIMEWIDTH_OF_SCROLL = 3500;
        TIMEWIDTH_OF_REST = 499;%TIMEWIDTH_OF_REST = 3999 - TIMEWIDTH_OF_RESTとなる様に設定

        array_angle;
        %ゲインを格納する行列
        Matrix_GainData = NaN(20000, 1);
        
        arduinoPort;

        %fig及びcsvを保存するPathを指定
        filePath = 'C:\home\chen\MATLAB コード\2023_preExp\';


        %経過時間を記録するための変数
        timediff_msec;
        time_msec;

        %timediff_msec(Arduino１周期当たりの時間)とtime_msec(累計時間)を格納する行列
        Matrix_TimeData = NaN(20000, 2)

        %ボタン押下のタイムスタンプをCSVに保存するための変数
        timestamp_count = 0;
        vector_timestampData = NaN(20000, 1);

        %制御偏差、微分値、積分値を格納する行列
        Matrix_DerivationData = NaN(20000, 9);
        %各値を保持するオブジェクトの名前を格納するcell配列
        Derivation_label

        %平均誤差を格納する行列
        Matrix_errorData = NaN(20000, 3);
        
        %切替の許可時間と切り替え時間を格納する行列
        Matrix_SwitchingtimeData = NaN(20000, 2);

        %書き出しが終わった瞬間上がるフラグ
        isExportFinished = false;

        f;

        counter = 0;
        flagSerialActive = false;

        flagFirstDraw = true;
        pltGraph1_AngleCurrent
        pltGraph1_AngleTarget;
        pltGraph1_PWM;
        pltGraph2_AngleCurrent
        pltGraph2_AngleTarget;
        pltGraph2_PWM;
        pltGraph3_AngleCurrent
        pltGraph3_AngleTarget;
        pltGraph3_PWM;

    end

    properties (Access = public)
        

    end





    methods (Access = private)
        %モジュールの位置をループごとに描画する関数
        function PosDisCallback(app, arg1, arg2, arg3)

            % それぞれの関節の位置をベクトル v1, v2, v3 で指定
            angle_Joint3 = deg2rad(arg3);
            angle_Joint2 = deg2rad(arg2);
            angle_Joint1= deg2rad(arg1);
            v1 = 0.3 * [cos(angle_Joint3+pi/2), sin(angle_Joint3+pi/2)];
            v2 = 0.3 * [cos(angle_Joint2 + angle_Joint3 + pi/2), sin(angle_Joint2 + angle_Joint3 + pi/2)];
            v3 = 0.3 * [cos(angle_Joint1 + angle_Joint2 + angle_Joint3 + pi/2), sin(angle_Joint1 + angle_Joint2 + angle_Joint3 + pi/2)];

            th_tgt1 = deg2rad(app.targetangle_1.Value);
            th_tgt2 = deg2rad(app.targetangle_2.Value);
            th_tgt3 = deg2rad(app.targetangle_3.Value);

            v_target1 = 0.3 * [cos(th_tgt3+pi/2), sin(th_tgt3+pi/2)];
            v_target2 = 0.3 * [cos(th_tgt2 + th_tgt3 + pi/2), sin(th_tgt2 + th_tgt3 + pi/2)];
            v_target3 = 0.3 * [cos(th_tgt1 + th_tgt2 + th_tgt3 + pi/2), sin(th_tgt1 + th_tgt2 + th_tgt3 + pi/2)];


            x = [0.5, 0.5 + v1(1), 0.5 + v1(1) + v2(1), 0.5 + v1(1) + v2(1) + v3(1)];
            y = [0, v1(2), v1(2) + v2(2), v1(2) + v2(2) + v3(2)];

            xt = [0.5, 0.5 + v_target1(1), 0.5 + v_target1(1) + v_target2(1), 0.5 + v_target1(1) + v_target2(1) + v_target3(1)];
            yt = [0, v_target1(2), v_target1(2) + v_target2(2), v_target1(2) + v_target2(2) + v_target3(2)];
            cla(app.PositionGraph);
            % 軸を保持しつつ、プロットを更新

            plot(app.PositionGraph, [x(1), x(2)], [y(1), y(2)], 'Color', 'green', 'LineWidth', 4);
            hold (app.PositionGraph, 'on');
            plot(app.PositionGraph, [x(2), x(3)], [y(2), y(3)], 'Color', 'red', 'LineWidth', 4);
            plot(app.PositionGraph, [x(3), x(4)], [y(3), y(4)], 'Color', 'blue', 'LineWidth', 4);
            plot(app.PositionGraph, [xt(1), xt(2)], [yt(1), yt(2)], 'Color', [0.95 0.98 0.93], 'LineWidth', 4);
            plot(app.PositionGraph, [xt(2), xt(3)], [yt(2), yt(3)], 'Color', [0.98 0.89 0.91], 'LineWidth', 4);
            plot(app.PositionGraph, [xt(3), xt(4)], [yt(3), yt(4)], 'Color', [0.90 0.96 1], 'LineWidth', 4);

            hold (app.PositionGraph, 'off');
        end
        %-------------------------------------------------------------------------------------------------------------------------------------------------------------
        function VarDisCallback(app, arg1, arg2, arg3)

            app.Matrix_AngleData(app.plot_count, 1) = arg1;

            app.Matrix_AngleData(app.plot_count, 2) = app.targetangle_1.Value;

            app.Matrix_AngleData(app.plot_count, 3) = arg2;

            app.Matrix_AngleData(app.plot_count, 4) = app.targetangle_2.Value;

            app.Matrix_AngleData(app.plot_count, 5) = arg3;

            app.Matrix_AngleData(app.plot_count, 6) = app.targetangle_3.Value;

            app.Matrix_PWMData(app.plot_count, 1) = app.MDpwm_1.Value;
            app.Matrix_PWMData(app.plot_count, 2) = app.MDpwm_2.Value;
            app.Matrix_PWMData(app.plot_count, 3) = app.MDpwm_3.Value;



            % cla(app.TimeGraph_1);
            % cla(app.TimeGraph_2);
            % cla(app.TimeGraph_3);

            %データを格納する行列のサイズが40000なのに対して視認用のグラフの横軸サイズは4000
            %データがグラフの途中まで来たらスクロールを開始

            %if app.plot_count <= app.scroll_timeWidth
            if app.flagFirstDraw
                app.flagFirstDraw = false;
                app.pltGraph1_AngleCurrent = plot(app.TimeGraph_1, app.vector_timeax_of_drawgraph, app.Matrix_AngleData(1:4000, 1), 'Color', 'blue', 'LineWidth', 2);
                hold(app.TimeGraph_1, 'on');
                app.pltGraph1_AngleTarget = plot(app.TimeGraph_1, app.vector_timeax_of_drawgraph, app.Matrix_AngleData(1:4000, 2), 'Color', 'blue', 'LineWidth',  2, LineStyle=':');
                app.pltGraph1_PWM = plot(app.TimeGraph_1, app.vector_timeax_of_drawgraph, app.Matrix_PWMData(1:4000, 1), 'Color', 'black', 'LineWidth', 1.5);
                hold (app.TimeGraph_1, 'off');

                app.pltGraph2_AngleCurrent = plot(app.TimeGraph_2, app.vector_timeax_of_drawgraph, app.Matrix_AngleData(1:4000, 3), 'Color', 'red', 'LineWidth', 2);
                hold(app.TimeGraph_2, 'on');
                app.pltGraph2_AngleTarget = plot(app.TimeGraph_2, app.vector_timeax_of_drawgraph, app.Matrix_AngleData(1:4000, 4), 'Color', 'red', 'LineWidth', 2, LineStyle=':');
                app.pltGraph2_PWM = plot(app.TimeGraph_2, app.vector_timeax_of_drawgraph, app.Matrix_PWMData(1:4000, 2), 'Color', 'black', 'LineWidth', 1.5);
                hold (app.TimeGraph_2, 'off');

                app.pltGraph3_AngleCurrent = plot(app.TimeGraph_3, app.vector_timeax_of_drawgraph, app.Matrix_AngleData(1:4000, 5), 'Color', 'green', 'LineWidth', 2);
                hold(app.TimeGraph_3, 'on');
                app.pltGraph3_AngleTarget = plot(app.TimeGraph_3, app.vector_timeax_of_drawgraph, app.Matrix_AngleData(1:4000, 6), 'Color', 'green', 'LineWidth', 2, LineStyle=':');
                app.pltGraph3_PWM = plot(app.TimeGraph_3, app.vector_timeax_of_drawgraph, app.Matrix_PWMData(1:4000, 3), 'Color', 'black', 'LineWidth', 1.5);
                hold (app.TimeGraph_1, 'off');                
            elseif rem(app.counter, app.DRAW_INTERVAL_OF_TIME_GRAPH ) == 0
                if app.plot_count < app.TIMEWIDTH_OF_SCROLL + 1
                    app.pltGraph1_AngleCurrent.YData = app.Matrix_AngleData(1:4000, 1);
                    app.pltGraph1_AngleTarget.YData = app.Matrix_AngleData(1:4000, 2);
                    app.pltGraph1_PWM.YData = app.Matrix_PWMData(1:4000, 1);

                    app.pltGraph2_AngleCurrent.YData = app.Matrix_AngleData(1:4000, 3);
                    app.pltGraph2_AngleTarget.YData = app.Matrix_AngleData(1:4000, 4);
                    app.pltGraph2_PWM.YData = app.Matrix_PWMData(1:4000, 2);

                    app.pltGraph3_AngleCurrent.YData = app.Matrix_AngleData(1:4000, 5);
                    app.pltGraph3_AngleTarget.YData = app.Matrix_AngleData(1:4000, 6);
                    app.pltGraph3_PWM.YData = app.Matrix_PWMData(1:4000, 3);
                elseif app.plot_count >= app.TIMEWIDTH_OF_SCROLL + 1
                    app.pltGraph1_AngleCurrent.YData = app.Matrix_AngleData(app.plot_count - app.TIMEWIDTH_OF_SCROLL : app.plot_count + app.TIMEWIDTH_OF_REST, 1);
                    app.pltGraph1_AngleTarget.YData = app.Matrix_AngleData(app.plot_count - app.TIMEWIDTH_OF_SCROLL : app.plot_count + app.TIMEWIDTH_OF_REST, 2);
                    app.pltGraph1_PWM.YData = app.Matrix_PWMData(app.plot_count - app.TIMEWIDTH_OF_SCROLL : app.plot_count + app.TIMEWIDTH_OF_REST, 1);

                    app.pltGraph2_AngleCurrent.YData = app.Matrix_AngleData(app.plot_count - app.TIMEWIDTH_OF_SCROLL : app.plot_count + app.TIMEWIDTH_OF_REST, 3);
                    app.pltGraph2_AngleTarget.YData = app.Matrix_AngleData(app.plot_count - app.TIMEWIDTH_OF_SCROLL : app.plot_count + app.TIMEWIDTH_OF_REST, 4);
                    app.pltGraph2_PWM.YData = app.Matrix_PWMData(app.plot_count - app.TIMEWIDTH_OF_SCROLL : app.plot_count + app.TIMEWIDTH_OF_REST, 2);

                    app.pltGraph3_AngleCurrent.YData = app.Matrix_AngleData(app.plot_count - app.TIMEWIDTH_OF_SCROLL : app.plot_count + app.TIMEWIDTH_OF_REST, 5);
                    app.pltGraph3_AngleTarget.YData = app.Matrix_AngleData(app.plot_count - app.TIMEWIDTH_OF_SCROLL : app.plot_count + app.TIMEWIDTH_OF_REST, 6);
                    app.pltGraph3_PWM.YData = app.Matrix_PWMData(app.plot_count - app.TIMEWIDTH_OF_SCROLL : app.plot_count + app.TIMEWIDTH_OF_REST, 3);
                end
            %     plot(app.TimeGraph_1, app.timeax_Graph, app.AngleData(app.plot_count - app.scroll_timeWidth : app.plot_count + app.rest_timeWidth, 1), 'Color', 'blue', 'LineWidth', 2);
            %     hold(app.TimeGraph_1, 'on');
            %     plot(app.TimeGraph_1, app.timeax_Graph, app.AngleData(app.plot_count - app.scroll_timeWidth : app.plot_count + app.rest_timeWidth, 2), 'Color', 'blue', 'LineWidth', 2, LineStyle=':');
            %     plot(app.TimeGraph_1, app.timeax_Graph, app.PWMData(app.plot_count - app.scroll_timeWidth : app.plot_count + app.rest_timeWidth, 1), 'Color', 'black', 'LineWidth', 1.5);
            %     hold (app.TimeGraph_1, 'off');
            % 
            %     plot(app.TimeGraph_2, app.timeax_Graph, app.AngleData(app.plot_count - app.scroll_timeWidth : app.plot_count + app.rest_timeWidth, 3), 'Color', 'red', 'LineWidth', 2);
            %     hold(app.TimeGraph_2, 'on');
            %     plot(app.TimeGraph_2, app.timeax_Graph, app.AngleData(app.plot_count - app.scroll_timeWidth : app.plot_count + app.rest_timeWidth, 4), 'Color', 'red', 'LineWidth', 2, LineStyle=':');
            %     plot(app.TimeGraph_2, app.timeax_Graph, app.PWMData(app.plot_count - app.scroll_timeWidth : app.plot_count + app.rest_timeWidth, 2), 'Color', 'black', 'LineWidth', 1.5);
            %     hold (app.TimeGraph_2, 'off');
            % 
            %     plot(app.TimeGraph_3, app.timeax_Graph, app.AngleData(app.plot_count - app.scroll_timeWidth : app.plot_count + app.rest_timeWidth, 5), 'Color', 'green', 'LineWidth', 2);
            %     hold(app.TimeGraph_3, 'on');
            %     plot(app.TimeGraph_3, app.timeax_Graph, app.AngleData(app.plot_count - app.scroll_timeWidth : app.plot_count + app.rest_timeWidth, 6), 'Color', 'green', 'LineWidth', 2, LineStyle=':');
            %     plot(app.TimeGraph_3, app.timeax_Graph, app.PWMData(app.plot_count - app.scroll_timeWidth : app.plot_count + app.rest_timeWidth, 3), 'Color', 'black', 'LineWidth', 1.5);
            %     hold (app.TimeGraph_1, 'off');
            end
        end
        %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        function StoreDerivationData(app)
            for i = 1:9
                app.Matrix_DerivationData(app.plot_count, i) = app.Derivation_label{i}.Value;
            end
        end

        function Serialcommunicate(app)

            while isvalid(app.UIFigure) && app.isExportFinished == false

                %Arduinoからデータ受信

                try
                    tic
                    data = readline(app.arduinoPort);
                    app.counter = app.counter + 1;
                    data_parts = strsplit(data, {',',':'});

                    %{
                       通信する文字リスト
                       2: 関節１の現在角
                       4: 関節１の目標角
                       6: 関節２の現在角
                       8: 関節２の目標角
                       10: 関節３の現在角
                       12: 関節３の目標角
                       14: 累計時間
                       16: 関節１の制御偏差
                       18: 関節２の制御偏差
                       20: 関節３の制御偏差
                       22: 関節１の微分値
                       24: 関節２の微分値
                       26: 関節３の微分値
                       28: 関節１の積分値
                       30: 関節２の積分値
                       32: 関節３の積分値 
                       34: 関節１のデューティー比
                       36: 関節２のデューティー比
                       38: 関節３のデューティー比
                       40: Arduino1周期の時間
                    %}


                    ang1 = str2double(data_parts(2));
                    app.angle_1.Value = ang1;

                    app.targetangle_1.Value = str2double(data_parts(4));

                    ang2 = str2double(data_parts(6));
                    app.angle_2.Value = ang2;

                    app.targetangle_2.Value = str2double(data_parts(8));

                    ang3 = str2double(data_parts(10));
                    app.angle_3.Value = ang3;

                    app.targetangle_3.Value = str2double(data_parts(12));

                    app.time_msec = str2double(data_parts(14));


                    app.diff_1.Value = str2double(data_parts(16));
                    app.diff_2.Value = str2double(data_parts(18));
                    app.diff_3.Value = str2double(data_parts(20));

                    app.deri_1.Value = str2double(data_parts(22));
                    app.deri_2.Value = str2double(data_parts(24));
                    app.deri_3.Value = str2double(data_parts(26));

                    app.dsum_1.Value = str2double(data_parts(28));
                    app.dsum_2.Value = str2double(data_parts(30));
                    app.dsum_3.Value = str2double(data_parts(32));


                    app.MDpwm_1.Value = str2double(data_parts(34));
                    app.MDpwm_2.Value = str2double(data_parts(36));
                    app.MDpwm_3.Value = str2double(data_parts(38));

                    app.error_1.Value = str2double(data_parts(40));
                    app.Matrix_errorData(app.plot_count, 1) = app.error_1.Value;
                    app.error_2.Value = str2double(data_parts(42));
                    app.Matrix_errorData(app.plot_count, 2) = app.error_2.Value;
                    app.error_3.Value = str2double(data_parts(44));
                    app.Matrix_errorData(app.plot_count, 3) = app.error_3.Value;

                    app.timediff_msec = str2double(data_parts(46));
                    app.ArduinoPeriod.Value = app.timediff_msec;
                   
                    
                    app.Matrix_TimeData(app.plot_count, 1) = app.time_msec;
                    app.Matrix_TimeData(app.plot_count, 2) = app.timediff_msec;

                    app.time_approval.Value = str2double(data_parts(48));
                    app.Matrix_SwitchingtimeData(app.plot_count, 1) = app.time_approval.Value;
                    app.time_switching.Value = str2double(data_parts(50));
                    app.Matrix_SwitchingtimeData(app.plot_count, 2) = app.time_switching.Value;
                    
                    
                    StoreDerivationData(app);
                    app.plot_count = app.plot_count + 1;
                    
                    if rem(app.counter, app.DRAW_INTERVAL_OF_POS_GRAPH ) == 0
                        PosDisCallback(app, ang1, ang2, ang3);
                        
                    end
                    VarDisCallback(app, ang1, ang2, ang3);

                    % if rem(app.counter, 2) == 0
                    %     drawnow limiterate;
                    % end

                    elapsed_time = toc;                    
                    app.MatlabPeriod.Value = elapsed_time*1000;
                    % drawnow limiterate nocallbacks;
                    % drawnow limiterate;
                    % pause(0.01);

                catch
                    %シリアル通信のエラー
                    % warning('シリアル通信エラー')
                    pause(0.01);
                end

            end
            delete (app.arduinoPort);
        end

    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.angle_1.Value = 0;
            app.angle_2.Value = 0;
            app.angle_3.Value = 0;

            app.targetangle_1.Value = 0;
            app.targetangle_2.Value = 0;
            app.targetangle_3.Value = 0;

            app.Pgain_1.Value = num2str(0);
            app.Dgain_1.Value = num2str(0);
            app.Igain_1.Value = num2str(0);
            app.FFgain_1.Value = num2str(0);

            app.array_angle = [app.angle_1.Value app.angle_2.Value, app.angle_3.Value];
            app.Derivation_label = {app.diff_1, app.diff_2, app.diff_3, app.deri_1, app.deri_2, app.deri_3, app.dsum_1, app.dsum_2, app.dsum_3} ;
            double pot1;
            double pot2;
            double pot3;
            double ang1;
            double ang2;
            double ang3;

            while app.flagSerialActive == false
                pause(0.1)
            end
            Serialcommunicate(app);

        end

        % Button pushed function: OPENButton
        function OPENButtonPushed(app, event)
            app.OPENButton.BackgroundColor = 'g';
            app.arduinoPort = serialport("COM6", 115200, "Timeout", 0.05);
         
            pause(2);
            writeline(app.arduinoPort, "g");
            pause(2);
            gaindata = readline(app.arduinoPort);
            gaindata = strsplit(gaindata, {',',':'});
            app.Pgain_1.Value = gaindata(3);
            app.Matrix_GainData(1) = str2double(app.Pgain_1.Value);

            app.Dgain_1.Value = gaindata(5);
            app.Matrix_GainData(2) = str2double(app.Dgain_1.Value);

            app.Igain_1.Value = gaindata(7);
            app.Matrix_GainData(3) = str2double(app.Igain_1.Value);

            app.FFgain_1.Value = gaindata(9);
            app.Matrix_GainData(4) = str2double(app.FFgain_1.Value);

            app.Pgain_2.Value = gaindata(11);
            app.Matrix_GainData(5) = str2double(app.Pgain_2.Value);

            app.Dgain_2.Value = gaindata(13);
            app.Matrix_GainData(6) = str2double(app.Dgain_2.Value);

            app.Igain_2.Value = gaindata(15);
            app.Matrix_GainData(7) = str2double(app.Igain_2.Value);

            app.FFgain_2.Value = gaindata(17);
            app.Matrix_GainData(8) = str2double(app.FFgain_2.Value);

            app.Pgain_3.Value = gaindata(19);
            app.Matrix_GainData(9) = str2double(app.Pgain_3.Value);

            app.Dgain_3.Value = gaindata(21);
            app.Matrix_GainData(10) = str2double(app.Dgain_3.Value);

            app.Igain_3.Value = gaindata(23);
            app.Matrix_GainData(11) = str2double(app.Igain_3.Value);

            app.FFgain_3.Value = gaindata(25);
            app.Matrix_GainData(12) = str2double(app.FFgain_3.Value);

        end

        % Button pushed function: CONTROLButton
        function CONTROLButtonPushed(app, event)
            %app.f = parfeval(backgroundPool,@Serialcommunicate,0,app);
            writeline(app.arduinoPort, "s");
            % Serialcommunicate(app);
            app.CONTROLButton.BackgroundColor = 'g';
            app.flagSerialActive = true;
        end

        % Button pushed function: WRITEButton
        function WRITEButtonPushed(app, event)
            app.WRITEButton.BackgroundColor = 'g';


            date = string(datetime('now', 'Format', 'yyyyMMdd_HHmm'));

            %csvname = strcat('kp_', p, '_kd_', d, '_ki_', i, '_kff_', ff, '_', date, '.csv');
            csvname = strcat(date, '.csv');
            filepath_csv = fullfile(app.filePath, csvname);
            T = array2table([app.Matrix_AngleData app.Matrix_TimeData app.Matrix_PWMData app.Matrix_DerivationData...
                app.Matrix_errorData app.vector_timestampData app.Matrix_SwitchingtimeData app.Matrix_GainData ]);
            
            T.Properties.VariableNames = {'ang1', 'tgtang1', 'ang2', 'tgtang2',  'ang3', 'tgtang3',...
                't', 'dt', 'PWM1', 'PWM2', 'PWM3',  'diff1', 'diff2', 'diff3', 'deri1', 'deri2', 'deri3', 'dsum1', 'dsum2', 'dsum3', ...
                'error1', 'error2', 'error3', 'timestamp', 'approval', 'switching' 'gain'};
            writetable(T, filepath_csv);

            %figname = strcat('kp_', p, '_kd_', d, '_ki_', i, '_kff_', ff, '_', date, '.fig');
            figname = strcat(date, '.fig');
            figure;
            filepath_fig = fullfile(app.filePath, figname);
            for indexJoint = 1:3
                subplot(3,1,indexJoint)
                plot(app.vector_timeax, [app.Matrix_AngleData(:,2*indexJoint-1:2*indexJoint) app.Matrix_PWMData(:,indexJoint)]);
            end
            
            savefig(filepath_fig);

        end

        % Button pushed function: Button_2
        function Angle1_plus(app, event)
            writeline(app.arduinoPort, 't');
            app.timestamp_count = app.timestamp_count + 2;
            app.vector_timestampData(app.timestamp_count) = app.plot_count;
            app.timestamp_count = app.timestamp_count + 1;
            app.vector_timestampData(app.timestamp_count) = 1;
        end

        % Button pushed function: Button_8
        function Angle2_plus(app, event)
            writeline(app.arduinoPort, 'g');
            app.timestamp_count = app.timestamp_count + 2;
            app.vector_timestampData(app.timestamp_count) = app.plot_count;
            app.timestamp_count = app.timestamp_count + 1;
            app.vector_timestampData(app.timestamp_count) = 2;
        end

        % Button pushed function: Button_9
        function Angle3_plus(app, event)
            writeline(app.arduinoPort, 'b');
            app.timestamp_count = app.timestamp_count + 2;
            app.vector_timestampData(app.timestamp_count) = app.plot_count;
            app.timestamp_count = app.timestamp_count + 1;
            app.vector_timestampData(app.timestamp_count) = 3;
        end

        % Button pushed function: Button_3
        function Button_3Pushed(app, event)
            writeline(app.arduinoPort, 'y');
            app.timestamp_count = app.timestamp_count + 2;
            app.vector_timestampData(app.timestamp_count) = app.plot_count;
            app.timestamp_count = app.timestamp_count + 1;
            app.vector_timestampData(app.timestamp_count) = 4;
        end

        % Button pushed function: Button_10
        function Button_10Pushed(app, event)
            writeline(app.arduinoPort, 'h');
            app.timestamp_count = app.timestamp_count + 2;
            app.vector_timestampData(app.timestamp_count) = app.plot_count;
            app.timestamp_count = app.timestamp_count + 1;
            app.vector_timestampData(app.timestamp_count) = 5;
        end

        % Button pushed function: Button_11
        function Button_11Pushed(app, event)
            writeline(app.arduinoPort, 'n');
            app.timestamp_count = app.timestamp_count + 2;
            app.vector_timestampData(app.timestamp_count) = app.plot_count;
            app.timestamp_count = app.timestamp_count + 1;
            app.vector_timestampData(app.timestamp_count) = 6;
        end

        % Button pushed function: STOPButton
        function STOPButtonPushed(app, event)
            app.isExportFinished = true;
            app.STOPButton.BackgroundColor = 'g';
            app.WRITEButton.Enable = 'on';
        end

        % Button pushed function: SWITCHButton
        function SWITCHButtonPushed(app, event)
            writeline(app.arduinoPort, 'w')
            app.SWITCHButton.BackgroundColor = 'g';
        end

        % Selection changed function: ButtonGroup
        function ButtonGroupSelectionChanged(app, event)
            selectedButton = app.ButtonGroup.SelectedObject;
            if selectedButton == app.directedVoltageMode
                writeline(app.arduinoPort, 'd');
            elseif selectedButton == app.jointAngleMode
                writeline(app.arduinoPort, 'j');
            end
            disp('Matrix_GainData after assignment:');
            %switchボタンをenableにするべき
            app.SWITCHButton.Enable = 'on';
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [1 1 1];
            app.UIFigure.Position = [0 42 1440 888];
            app.UIFigure.Name = 'MATLAB App';

            % Create PositionGraph
            app.PositionGraph = uiaxes(app.UIFigure);
            zlabel(app.PositionGraph, 'Z')
            app.PositionGraph.CameraPosition = [0.5 0.5 9.16025403784439];
            app.PositionGraph.CameraTarget = [0.5 0.5 0.5];
            app.PositionGraph.CameraUpVector = [0 1 0];
            app.PositionGraph.CameraViewAngle = 6.60861036031192;
            app.PositionGraph.DataAspectRatio = [1 1 1];
            app.PositionGraph.PlotBoxAspectRatio = [1 1 1];
            app.PositionGraph.XLim = [0 1];
            app.PositionGraph.YLim = [0 1];
            app.PositionGraph.ZLim = [0 1];
            app.PositionGraph.XColor = [0.15 0.15 0.15];
            app.PositionGraph.XTick = [0 0.2 0.4 0.6 0.8 1];
            app.PositionGraph.XTickLabel = '';
            app.PositionGraph.YColor = [0.15 0.15 0.15];
            app.PositionGraph.YTick = [0 0.2 0.4 0.6 0.8 1];
            app.PositionGraph.YTickLabel = {''; ''; ''; ''; ''; ''};
            app.PositionGraph.ZColor = [0.15 0.15 0.15];
            app.PositionGraph.GridAlpha = 0.15;
            app.PositionGraph.MinorGridAlpha = 0.25;
            app.PositionGraph.Position = [875 230 565 471];

            % Create OPENButton
            app.OPENButton = uibutton(app.UIFigure, 'push');
            app.OPENButton.ButtonPushedFcn = createCallbackFcn(app, @OPENButtonPushed, true);
            app.OPENButton.BackgroundColor = [1 0 0];
            app.OPENButton.FontName = 'メイリオ';
            app.OPENButton.FontSize = 18;
            app.OPENButton.FontWeight = 'bold';
            app.OPENButton.FontColor = [1 1 1];
            app.OPENButton.Position = [1075 841 100 30];
            app.OPENButton.Text = 'OPEN';

            % Create ArduinomsLabel
            app.ArduinomsLabel = uilabel(app.UIFigure);
            app.ArduinomsLabel.HorizontalAlignment = 'center';
            app.ArduinomsLabel.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.ArduinomsLabel.FontSize = 22;
            app.ArduinomsLabel.FontWeight = 'bold';
            app.ArduinomsLabel.Position = [919 190 181 28];
            app.ArduinomsLabel.Text = 'Arduino周期(us)';

            % Create ArduinoPeriod
            app.ArduinoPeriod = uieditfield(app.UIFigure, 'numeric');
            app.ArduinoPeriod.HorizontalAlignment = 'center';
            app.ArduinoPeriod.FontSize = 22;
            app.ArduinoPeriod.Position = [984 130 133 61];

            % Create MatlabmsLabel
            app.MatlabmsLabel = uilabel(app.UIFigure);
            app.MatlabmsLabel.HorizontalAlignment = 'center';
            app.MatlabmsLabel.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.MatlabmsLabel.FontSize = 22;
            app.MatlabmsLabel.FontWeight = 'bold';
            app.MatlabmsLabel.Position = [1151 190 173 28];
            app.MatlabmsLabel.Text = 'Matlab周期(ms)';

            % Create MatlabPeriod
            app.MatlabPeriod = uieditfield(app.UIFigure, 'numeric');
            app.MatlabPeriod.HorizontalAlignment = 'center';
            app.MatlabPeriod.FontSize = 22;
            app.MatlabPeriod.Position = [1202 131 133 60];

            % Create CONTROLButton
            app.CONTROLButton = uibutton(app.UIFigure, 'push');
            app.CONTROLButton.ButtonPushedFcn = createCallbackFcn(app, @CONTROLButtonPushed, true);
            app.CONTROLButton.BackgroundColor = [1 0 0];
            app.CONTROLButton.FontName = 'メイリオ';
            app.CONTROLButton.FontSize = 18;
            app.CONTROLButton.FontWeight = 'bold';
            app.CONTROLButton.FontColor = [1 1 1];
            app.CONTROLButton.Position = [1072 768 107 30];
            app.CONTROLButton.Text = 'CONTROL';

            % Create Panel_6
            app.Panel_6 = uipanel(app.UIFigure);
            app.Panel_6.BorderType = 'none';
            app.Panel_6.TitlePosition = 'centertop';
            app.Panel_6.BackgroundColor = [1 0.9608 1];
            app.Panel_6.Position = [11 299 899 290];

            % Create TimeGraph_2
            app.TimeGraph_2 = uiaxes(app.Panel_6);
            zlabel(app.TimeGraph_2, 'Z')
            app.TimeGraph_2.XLim = [0 4000];
            app.TimeGraph_2.YLim = [-40 40];
            app.TimeGraph_2.ZLim = [0 1];
            app.TimeGraph_2.GridLineWidth = 1.5;
            app.TimeGraph_2.MinorGridLineWidth = 1.5;
            app.TimeGraph_2.XTick = [];
            app.TimeGraph_2.GridColor = [0.15 0.15 0.15];
            app.TimeGraph_2.MinorGridColor = [0.1 0.1 0.1];
            app.TimeGraph_2.GridAlpha = 0.15;
            app.TimeGraph_2.MinorGridAlpha = 0.25;
            app.TimeGraph_2.YGrid = 'on';
            app.TimeGraph_2.Position = [171 5 696 246];

            % Create Label_15
            app.Label_15 = uilabel(app.Panel_6);
            app.Label_15.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.Label_15.FontSize = 18;
            app.Label_15.FontWeight = 'bold';
            app.Label_15.Position = [12 243 126 57];
            app.Label_15.Text = '関節2';

            % Create tgtLabel_3
            app.tgtLabel_3 = uilabel(app.Panel_6);
            app.tgtLabel_3.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.tgtLabel_3.FontSize = 14;
            app.tgtLabel_3.FontWeight = 'bold';
            app.tgtLabel_3.Position = [11 227 39 22];
            app.tgtLabel_3.Text = 'θtgt';

            % Create Label_18
            app.Label_18 = uilabel(app.Panel_6);
            app.Label_18.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.Label_18.FontSize = 14;
            app.Label_18.FontWeight = 'bold';
            app.Label_18.Position = [11 187 25 22];
            app.Label_18.Text = 'θ';

            % Create PWMLabel_2
            app.PWMLabel_2 = uilabel(app.Panel_6);
            app.PWMLabel_2.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.PWMLabel_2.FontSize = 14;
            app.PWMLabel_2.FontWeight = 'bold';
            app.PWMLabel_2.Position = [11 27 41 22];
            app.PWMLabel_2.Text = 'PWM';

            % Create diffLabel_2
            app.diffLabel_2 = uilabel(app.Panel_6);
            app.diffLabel_2.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.diffLabel_2.FontSize = 14;
            app.diffLabel_2.FontWeight = 'bold';
            app.diffLabel_2.Position = [11 147 29 22];
            app.diffLabel_2.Text = 'diff';

            % Create deriLabel_2
            app.deriLabel_2 = uilabel(app.Panel_6);
            app.deriLabel_2.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.deriLabel_2.FontSize = 14;
            app.deriLabel_2.FontWeight = 'bold';
            app.deriLabel_2.Position = [11 107 31 22];
            app.deriLabel_2.Text = 'deri';

            % Create dsumLabel_2
            app.dsumLabel_2 = uilabel(app.Panel_6);
            app.dsumLabel_2.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.dsumLabel_2.FontSize = 14;
            app.dsumLabel_2.FontWeight = 'bold';
            app.dsumLabel_2.Position = [11 67 44 22];
            app.dsumLabel_2.Text = 'dsum';

            % Create targetangle_2
            app.targetangle_2 = uieditfield(app.Panel_6, 'numeric');
            app.targetangle_2.Limits = [-40 40];
            app.targetangle_2.Editable = 'off';
            app.targetangle_2.HorizontalAlignment = 'center';
            app.targetangle_2.FontSize = 18;
            app.targetangle_2.FontWeight = 'bold';
            app.targetangle_2.BackgroundColor = [1 0.9608 1];
            app.targetangle_2.Position = [71 222 60 28];

            % Create angle_2
            app.angle_2 = uieditfield(app.Panel_6, 'numeric');
            app.angle_2.Editable = 'off';
            app.angle_2.HorizontalAlignment = 'center';
            app.angle_2.FontSize = 18;
            app.angle_2.FontWeight = 'bold';
            app.angle_2.BackgroundColor = [1 0.9608 1];
            app.angle_2.Position = [71 182 60 28];

            % Create MDpwm_2
            app.MDpwm_2 = uieditfield(app.Panel_6, 'numeric');
            app.MDpwm_2.Editable = 'off';
            app.MDpwm_2.HorizontalAlignment = 'center';
            app.MDpwm_2.FontSize = 18;
            app.MDpwm_2.FontWeight = 'bold';
            app.MDpwm_2.BackgroundColor = [1 0.9608 1];
            app.MDpwm_2.Position = [71 22 60 28];

            % Create diff_2
            app.diff_2 = uieditfield(app.Panel_6, 'numeric');
            app.diff_2.Editable = 'off';
            app.diff_2.HorizontalAlignment = 'center';
            app.diff_2.FontSize = 18;
            app.diff_2.FontWeight = 'bold';
            app.diff_2.BackgroundColor = [1 0.9608 1];
            app.diff_2.Position = [71 142 60 28];

            % Create deri_2
            app.deri_2 = uieditfield(app.Panel_6, 'numeric');
            app.deri_2.Editable = 'off';
            app.deri_2.HorizontalAlignment = 'center';
            app.deri_2.FontSize = 18;
            app.deri_2.FontWeight = 'bold';
            app.deri_2.BackgroundColor = [1 0.9608 1];
            app.deri_2.Position = [71 102 60 28];

            % Create dsum_2
            app.dsum_2 = uieditfield(app.Panel_6, 'numeric');
            app.dsum_2.Editable = 'off';
            app.dsum_2.HorizontalAlignment = 'center';
            app.dsum_2.FontWeight = 'bold';
            app.dsum_2.BackgroundColor = [1 0.9608 1];
            app.dsum_2.Position = [71 62 80 28];

            % Create KpLabel_3
            app.KpLabel_3 = uilabel(app.Panel_6);
            app.KpLabel_3.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KpLabel_3.FontSize = 14;
            app.KpLabel_3.FontWeight = 'bold';
            app.KpLabel_3.Position = [210 257 26 22];
            app.KpLabel_3.Text = 'Kp';

            % Create Pgain_2
            app.Pgain_2 = uieditfield(app.Panel_6, 'text');
            app.Pgain_2.Editable = 'off';
            app.Pgain_2.FontSize = 18;
            app.Pgain_2.FontWeight = 'bold';
            app.Pgain_2.Position = [240 250 69 30];

            % Create KdLabel_3
            app.KdLabel_3 = uilabel(app.Panel_6);
            app.KdLabel_3.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KdLabel_3.FontSize = 14;
            app.KdLabel_3.FontWeight = 'bold';
            app.KdLabel_3.Position = [330 257 26 22];
            app.KdLabel_3.Text = 'Kd';

            % Create Dgain_2
            app.Dgain_2 = uieditfield(app.Panel_6, 'text');
            app.Dgain_2.Editable = 'off';
            app.Dgain_2.FontSize = 18;
            app.Dgain_2.FontWeight = 'bold';
            app.Dgain_2.Position = [360 249 70 30];

            % Create KiLabel_4
            app.KiLabel_4 = uilabel(app.Panel_6);
            app.KiLabel_4.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KiLabel_4.FontSize = 14;
            app.KiLabel_4.FontWeight = 'bold';
            app.KiLabel_4.Position = [450 257 25 22];
            app.KiLabel_4.Text = 'Ki';

            % Create Igain_2
            app.Igain_2 = uieditfield(app.Panel_6, 'text');
            app.Igain_2.Editable = 'off';
            app.Igain_2.FontSize = 18;
            app.Igain_2.FontWeight = 'bold';
            app.Igain_2.Position = [470 251 70 30];

            % Create KffLabel_2
            app.KffLabel_2 = uilabel(app.Panel_6);
            app.KffLabel_2.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KffLabel_2.FontSize = 14;
            app.KffLabel_2.FontWeight = 'bold';
            app.KffLabel_2.Position = [560 257 28 22];
            app.KffLabel_2.Text = 'Kff';

            % Create FFgain_2
            app.FFgain_2 = uieditfield(app.Panel_6, 'text');
            app.FFgain_2.Editable = 'off';
            app.FFgain_2.FontSize = 18;
            app.FFgain_2.FontWeight = 'bold';
            app.FFgain_2.Position = [590 250 70 30];

            % Create Button_8
            app.Button_8 = uibutton(app.Panel_6, 'push');
            app.Button_8.ButtonPushedFcn = createCallbackFcn(app, @Angle2_plus, true);
            app.Button_8.Icon = fullfile(pathToMLAPP, '左三角.png');
            app.Button_8.IconAlignment = 'center';
            app.Button_8.BackgroundColor = [1 1 1];
            app.Button_8.Position = [71 254 39 36];
            app.Button_8.Text = '';

            % Create Button_10
            app.Button_10 = uibutton(app.Panel_6, 'push');
            app.Button_10.ButtonPushedFcn = createCallbackFcn(app, @Button_10Pushed, true);
            app.Button_10.Icon = fullfile(pathToMLAPP, '右三角.png');
            app.Button_10.IconAlignment = 'center';
            app.Button_10.BackgroundColor = [1 1 1];
            app.Button_10.Position = [111 254 40 37];
            app.Button_10.Text = '';

            % Create error_2
            app.error_2 = uieditfield(app.Panel_6, 'numeric');
            app.error_2.Editable = 'off';
            app.error_2.HorizontalAlignment = 'center';
            app.error_2.FontSize = 18;
            app.error_2.FontWeight = 'bold';
            app.error_2.BackgroundColor = [1 0.9608 1];
            app.error_2.Position = [807 251 60 28];

            % Create Label_21
            app.Label_21 = uilabel(app.Panel_6);
            app.Label_21.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.Label_21.FontSize = 14;
            app.Label_21.FontWeight = 'bold';
            app.Label_21.Position = [773 255 33 22];
            app.Label_21.Text = '誤差';

            % Create Panel_7
            app.Panel_7 = uipanel(app.UIFigure);
            app.Panel_7.BorderType = 'none';
            app.Panel_7.BackgroundColor = [0.902 0.9608 1];
            app.Panel_7.Position = [10 589 899 290];

            % Create TimeGraph_1
            app.TimeGraph_1 = uiaxes(app.Panel_7);
            zlabel(app.TimeGraph_1, 'Z')
            app.TimeGraph_1.XLim = [0 4000];
            app.TimeGraph_1.YLim = [-60 60];
            app.TimeGraph_1.ZLim = [0 1];
            app.TimeGraph_1.GridLineWidth = 1.5;
            app.TimeGraph_1.MinorGridLineWidth = 1.5;
            app.TimeGraph_1.XTick = [];
            app.TimeGraph_1.GridColor = [0.15 0.15 0.15];
            app.TimeGraph_1.MinorGridColor = [0.1 0.1 0.1];
            app.TimeGraph_1.GridAlpha = 0.15;
            app.TimeGraph_1.MinorGridAlpha = 0.25;
            app.TimeGraph_1.YGrid = 'on';
            app.TimeGraph_1.Position = [171 4 690 246];

            % Create Label_14
            app.Label_14 = uilabel(app.Panel_7);
            app.Label_14.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.Label_14.FontSize = 18;
            app.Label_14.FontWeight = 'bold';
            app.Label_14.Position = [12 243 126 57];
            app.Label_14.Text = '関節1';

            % Create tgtLabel
            app.tgtLabel = uilabel(app.Panel_7);
            app.tgtLabel.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.tgtLabel.FontSize = 14;
            app.tgtLabel.FontWeight = 'bold';
            app.tgtLabel.Position = [11 228 39 22];
            app.tgtLabel.Text = 'θtgt';

            % Create Label_17
            app.Label_17 = uilabel(app.Panel_7);
            app.Label_17.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.Label_17.FontSize = 14;
            app.Label_17.FontWeight = 'bold';
            app.Label_17.Position = [11 188 25 22];
            app.Label_17.Text = 'θ';

            % Create targetangle_1
            app.targetangle_1 = uieditfield(app.Panel_7, 'numeric');
            app.targetangle_1.Limits = [-40 40];
            app.targetangle_1.Editable = 'off';
            app.targetangle_1.HorizontalAlignment = 'center';
            app.targetangle_1.FontSize = 18;
            app.targetangle_1.FontWeight = 'bold';
            app.targetangle_1.BackgroundColor = [0.902 0.9608 1];
            app.targetangle_1.Position = [71 222 60 28];

            % Create angle_1
            app.angle_1 = uieditfield(app.Panel_7, 'numeric');
            app.angle_1.Editable = 'off';
            app.angle_1.HorizontalAlignment = 'center';
            app.angle_1.FontSize = 18;
            app.angle_1.FontWeight = 'bold';
            app.angle_1.BackgroundColor = [0.902 0.9608 1];
            app.angle_1.Position = [71 182 60 28];

            % Create PWMLabel
            app.PWMLabel = uilabel(app.Panel_7);
            app.PWMLabel.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.PWMLabel.FontSize = 14;
            app.PWMLabel.FontWeight = 'bold';
            app.PWMLabel.Position = [11 28 41 22];
            app.PWMLabel.Text = 'PWM';

            % Create MDpwm_1
            app.MDpwm_1 = uieditfield(app.Panel_7, 'numeric');
            app.MDpwm_1.Editable = 'off';
            app.MDpwm_1.HorizontalAlignment = 'center';
            app.MDpwm_1.FontSize = 18;
            app.MDpwm_1.FontWeight = 'bold';
            app.MDpwm_1.BackgroundColor = [0.902 0.9608 1];
            app.MDpwm_1.Position = [71 23 60 28];

            % Create diff_1
            app.diff_1 = uieditfield(app.Panel_7, 'numeric');
            app.diff_1.Editable = 'off';
            app.diff_1.HorizontalAlignment = 'center';
            app.diff_1.FontSize = 18;
            app.diff_1.FontWeight = 'bold';
            app.diff_1.BackgroundColor = [0.902 0.9608 1];
            app.diff_1.Position = [71 142 60 28];

            % Create diffLabel
            app.diffLabel = uilabel(app.Panel_7);
            app.diffLabel.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.diffLabel.FontSize = 14;
            app.diffLabel.FontWeight = 'bold';
            app.diffLabel.Position = [11 148 29 22];
            app.diffLabel.Text = 'diff';

            % Create deri_1
            app.deri_1 = uieditfield(app.Panel_7, 'numeric');
            app.deri_1.Editable = 'off';
            app.deri_1.HorizontalAlignment = 'center';
            app.deri_1.FontSize = 18;
            app.deri_1.FontWeight = 'bold';
            app.deri_1.BackgroundColor = [0.902 0.9608 1];
            app.deri_1.Position = [71 102 60 28];

            % Create deriLabel
            app.deriLabel = uilabel(app.Panel_7);
            app.deriLabel.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.deriLabel.FontSize = 14;
            app.deriLabel.FontWeight = 'bold';
            app.deriLabel.Position = [11 108 31 22];
            app.deriLabel.Text = 'deri';

            % Create dsum_1
            app.dsum_1 = uieditfield(app.Panel_7, 'numeric');
            app.dsum_1.Editable = 'off';
            app.dsum_1.HorizontalAlignment = 'center';
            app.dsum_1.FontWeight = 'bold';
            app.dsum_1.BackgroundColor = [0.902 0.9608 1];
            app.dsum_1.Position = [71 62 81 28];

            % Create dsumLabel
            app.dsumLabel = uilabel(app.Panel_7);
            app.dsumLabel.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.dsumLabel.FontSize = 14;
            app.dsumLabel.FontWeight = 'bold';
            app.dsumLabel.Position = [11 68 44 22];
            app.dsumLabel.Text = 'dsum';

            % Create KpLabel_2
            app.KpLabel_2 = uilabel(app.Panel_7);
            app.KpLabel_2.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KpLabel_2.FontSize = 14;
            app.KpLabel_2.FontWeight = 'bold';
            app.KpLabel_2.Position = [211 258 26 22];
            app.KpLabel_2.Text = 'Kp';

            % Create Pgain_1
            app.Pgain_1 = uieditfield(app.Panel_7, 'text');
            app.Pgain_1.Editable = 'off';
            app.Pgain_1.FontSize = 18;
            app.Pgain_1.FontWeight = 'bold';
            app.Pgain_1.Position = [241 251 69 30];

            % Create KdLabel_2
            app.KdLabel_2 = uilabel(app.Panel_7);
            app.KdLabel_2.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KdLabel_2.FontSize = 14;
            app.KdLabel_2.FontWeight = 'bold';
            app.KdLabel_2.Position = [331 258 26 22];
            app.KdLabel_2.Text = 'Kd';

            % Create Dgain_1
            app.Dgain_1 = uieditfield(app.Panel_7, 'text');
            app.Dgain_1.Editable = 'off';
            app.Dgain_1.FontSize = 18;
            app.Dgain_1.FontWeight = 'bold';
            app.Dgain_1.Position = [361 250 70 30];

            % Create KiLabel_3
            app.KiLabel_3 = uilabel(app.Panel_7);
            app.KiLabel_3.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KiLabel_3.FontSize = 14;
            app.KiLabel_3.FontWeight = 'bold';
            app.KiLabel_3.Position = [451 258 25 22];
            app.KiLabel_3.Text = 'Ki';

            % Create Igain_1
            app.Igain_1 = uieditfield(app.Panel_7, 'text');
            app.Igain_1.Editable = 'off';
            app.Igain_1.FontSize = 18;
            app.Igain_1.FontWeight = 'bold';
            app.Igain_1.Position = [471 252 70 30];

            % Create KffLabel
            app.KffLabel = uilabel(app.Panel_7);
            app.KffLabel.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KffLabel.FontSize = 14;
            app.KffLabel.FontWeight = 'bold';
            app.KffLabel.Position = [561 258 28 22];
            app.KffLabel.Text = 'Kff';

            % Create FFgain_1
            app.FFgain_1 = uieditfield(app.Panel_7, 'text');
            app.FFgain_1.Editable = 'off';
            app.FFgain_1.FontSize = 18;
            app.FFgain_1.FontWeight = 'bold';
            app.FFgain_1.Position = [591 251 70 30];

            % Create Button_2
            app.Button_2 = uibutton(app.Panel_7, 'push');
            app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @Angle1_plus, true);
            app.Button_2.Icon = fullfile(pathToMLAPP, '左三角.png');
            app.Button_2.IconAlignment = 'center';
            app.Button_2.BackgroundColor = [1 1 1];
            app.Button_2.Position = [72 254 39 36];
            app.Button_2.Text = '';

            % Create Button_3
            app.Button_3 = uibutton(app.Panel_7, 'push');
            app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @Button_3Pushed, true);
            app.Button_3.Icon = fullfile(pathToMLAPP, '右三角.png');
            app.Button_3.IconAlignment = 'center';
            app.Button_3.BackgroundColor = [1 1 1];
            app.Button_3.Position = [112 253 40 37];
            app.Button_3.Text = '';

            % Create error_1
            app.error_1 = uieditfield(app.Panel_7, 'numeric');
            app.error_1.Editable = 'off';
            app.error_1.HorizontalAlignment = 'center';
            app.error_1.FontSize = 18;
            app.error_1.FontWeight = 'bold';
            app.error_1.BackgroundColor = [0.902 0.9608 1];
            app.error_1.Position = [808 251 60 28];

            % Create Label_20
            app.Label_20 = uilabel(app.Panel_7);
            app.Label_20.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.Label_20.FontSize = 14;
            app.Label_20.FontWeight = 'bold';
            app.Label_20.Position = [774 254 33 22];
            app.Label_20.Text = '誤差';

            % Create Panel_8
            app.Panel_8 = uipanel(app.UIFigure);
            app.Panel_8.BorderType = 'none';
            app.Panel_8.BackgroundColor = [0.949 0.9804 0.9294];
            app.Panel_8.Position = [12 9 899 290];

            % Create TimeGraph_3
            app.TimeGraph_3 = uiaxes(app.Panel_8);
            zlabel(app.TimeGraph_3, 'Z')
            app.TimeGraph_3.XLim = [0 4000];
            app.TimeGraph_3.YLim = [-60 60];
            app.TimeGraph_3.ZLim = [0 1];
            app.TimeGraph_3.GridLineWidth = 1.5;
            app.TimeGraph_3.MinorGridLineWidth = 1.5;
            app.TimeGraph_3.XTickLabel = {'0'; '500'; '1000'; '1500'; '2000'; '2500'; '3000'; '3500'; '4000'};
            app.TimeGraph_3.YTick = [-60 -40 -20 0 20 40 60];
            app.TimeGraph_3.YTickLabel = {'-60'; '-40'; '-20'; '0'; '20'; '40'; '60'};
            app.TimeGraph_3.GridColor = [0.15 0.15 0.15];
            app.TimeGraph_3.MinorGridColor = [0.1 0.1 0.1];
            app.TimeGraph_3.GridAlpha = 0.15;
            app.TimeGraph_3.MinorGridAlpha = 0.25;
            app.TimeGraph_3.YGrid = 'on';
            app.TimeGraph_3.Position = [161 5 697 246];

            % Create tgtLabel_4
            app.tgtLabel_4 = uilabel(app.Panel_8);
            app.tgtLabel_4.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.tgtLabel_4.FontSize = 14;
            app.tgtLabel_4.FontWeight = 'bold';
            app.tgtLabel_4.Position = [11 228 39 22];
            app.tgtLabel_4.Text = 'θtgt';

            % Create Label_19
            app.Label_19 = uilabel(app.Panel_8);
            app.Label_19.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.Label_19.FontSize = 14;
            app.Label_19.FontWeight = 'bold';
            app.Label_19.Position = [11 188 25 22];
            app.Label_19.Text = 'θ';

            % Create PWMLabel_3
            app.PWMLabel_3 = uilabel(app.Panel_8);
            app.PWMLabel_3.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.PWMLabel_3.FontSize = 14;
            app.PWMLabel_3.FontWeight = 'bold';
            app.PWMLabel_3.Position = [11 28 41 22];
            app.PWMLabel_3.Text = 'PWM';

            % Create diffLabel_3
            app.diffLabel_3 = uilabel(app.Panel_8);
            app.diffLabel_3.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.diffLabel_3.FontSize = 14;
            app.diffLabel_3.FontWeight = 'bold';
            app.diffLabel_3.Position = [11 148 29 22];
            app.diffLabel_3.Text = 'diff';

            % Create deriLabel_3
            app.deriLabel_3 = uilabel(app.Panel_8);
            app.deriLabel_3.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.deriLabel_3.FontSize = 14;
            app.deriLabel_3.FontWeight = 'bold';
            app.deriLabel_3.Position = [11 108 31 22];
            app.deriLabel_3.Text = 'deri';

            % Create dsumLabel_3
            app.dsumLabel_3 = uilabel(app.Panel_8);
            app.dsumLabel_3.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.dsumLabel_3.FontSize = 14;
            app.dsumLabel_3.FontWeight = 'bold';
            app.dsumLabel_3.Position = [11 68 44 22];
            app.dsumLabel_3.Text = 'dsum';

            % Create targetangle_3
            app.targetangle_3 = uieditfield(app.Panel_8, 'numeric');
            app.targetangle_3.Limits = [-40 40];
            app.targetangle_3.Editable = 'off';
            app.targetangle_3.HorizontalAlignment = 'center';
            app.targetangle_3.FontSize = 18;
            app.targetangle_3.FontWeight = 'bold';
            app.targetangle_3.BackgroundColor = [0.949 0.9804 0.9294];
            app.targetangle_3.Position = [71 222 60 28];

            % Create angle_3
            app.angle_3 = uieditfield(app.Panel_8, 'numeric');
            app.angle_3.Editable = 'off';
            app.angle_3.HorizontalAlignment = 'center';
            app.angle_3.FontSize = 18;
            app.angle_3.FontWeight = 'bold';
            app.angle_3.BackgroundColor = [0.949 0.9804 0.9294];
            app.angle_3.Position = [71 182 60 28];

            % Create diff_3
            app.diff_3 = uieditfield(app.Panel_8, 'numeric');
            app.diff_3.Editable = 'off';
            app.diff_3.HorizontalAlignment = 'center';
            app.diff_3.FontSize = 18;
            app.diff_3.FontWeight = 'bold';
            app.diff_3.BackgroundColor = [0.949 0.9804 0.9294];
            app.diff_3.Position = [71 143 60 28];

            % Create deri_3
            app.deri_3 = uieditfield(app.Panel_8, 'numeric');
            app.deri_3.Editable = 'off';
            app.deri_3.HorizontalAlignment = 'center';
            app.deri_3.FontSize = 18;
            app.deri_3.FontWeight = 'bold';
            app.deri_3.BackgroundColor = [0.949 0.9804 0.9294];
            app.deri_3.Position = [71 102 60 28];

            % Create dsum_3
            app.dsum_3 = uieditfield(app.Panel_8, 'numeric');
            app.dsum_3.Editable = 'off';
            app.dsum_3.HorizontalAlignment = 'center';
            app.dsum_3.FontWeight = 'bold';
            app.dsum_3.BackgroundColor = [0.949 0.9804 0.9294];
            app.dsum_3.Position = [71 62 79 28];

            % Create MDpwm_3
            app.MDpwm_3 = uieditfield(app.Panel_8, 'numeric');
            app.MDpwm_3.Editable = 'off';
            app.MDpwm_3.HorizontalAlignment = 'center';
            app.MDpwm_3.FontSize = 18;
            app.MDpwm_3.FontWeight = 'bold';
            app.MDpwm_3.BackgroundColor = [0.949 0.9804 0.9294];
            app.MDpwm_3.Position = [71 22 60 28];

            % Create Button_9
            app.Button_9 = uibutton(app.Panel_8, 'push');
            app.Button_9.ButtonPushedFcn = createCallbackFcn(app, @Angle3_plus, true);
            app.Button_9.Icon = fullfile(pathToMLAPP, '左三角.png');
            app.Button_9.IconAlignment = 'center';
            app.Button_9.BackgroundColor = [1 1 1];
            app.Button_9.Position = [70 255 39 36];
            app.Button_9.Text = '';

            % Create Button_11
            app.Button_11 = uibutton(app.Panel_8, 'push');
            app.Button_11.ButtonPushedFcn = createCallbackFcn(app, @Button_11Pushed, true);
            app.Button_11.Icon = fullfile(pathToMLAPP, '右三角.png');
            app.Button_11.IconAlignment = 'center';
            app.Button_11.BackgroundColor = [1 1 1];
            app.Button_11.Position = [110 254 40 37];
            app.Button_11.Text = '';

            % Create KpLabel_4
            app.KpLabel_4 = uilabel(app.Panel_8);
            app.KpLabel_4.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KpLabel_4.FontSize = 14;
            app.KpLabel_4.FontWeight = 'bold';
            app.KpLabel_4.Position = [211 257 26 22];
            app.KpLabel_4.Text = 'Kp';

            % Create Pgain_3
            app.Pgain_3 = uieditfield(app.Panel_8, 'text');
            app.Pgain_3.Editable = 'off';
            app.Pgain_3.FontSize = 18;
            app.Pgain_3.FontWeight = 'bold';
            app.Pgain_3.Position = [241 250 69 30];

            % Create KdLabel_4
            app.KdLabel_4 = uilabel(app.Panel_8);
            app.KdLabel_4.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KdLabel_4.FontSize = 14;
            app.KdLabel_4.FontWeight = 'bold';
            app.KdLabel_4.Position = [331 257 26 22];
            app.KdLabel_4.Text = 'Kd';

            % Create Dgain_3
            app.Dgain_3 = uieditfield(app.Panel_8, 'text');
            app.Dgain_3.Editable = 'off';
            app.Dgain_3.FontSize = 18;
            app.Dgain_3.FontWeight = 'bold';
            app.Dgain_3.Position = [361 249 70 30];

            % Create KiLabel_5
            app.KiLabel_5 = uilabel(app.Panel_8);
            app.KiLabel_5.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KiLabel_5.FontSize = 14;
            app.KiLabel_5.FontWeight = 'bold';
            app.KiLabel_5.Position = [451 257 25 22];
            app.KiLabel_5.Text = 'Ki';

            % Create Igain_3
            app.Igain_3 = uieditfield(app.Panel_8, 'text');
            app.Igain_3.Editable = 'off';
            app.Igain_3.FontSize = 18;
            app.Igain_3.FontWeight = 'bold';
            app.Igain_3.Position = [471 251 70 30];

            % Create KffLabel_3
            app.KffLabel_3 = uilabel(app.Panel_8);
            app.KffLabel_3.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.KffLabel_3.FontSize = 14;
            app.KffLabel_3.FontWeight = 'bold';
            app.KffLabel_3.Position = [561 257 28 22];
            app.KffLabel_3.Text = 'Kff';

            % Create FFgain_3
            app.FFgain_3 = uieditfield(app.Panel_8, 'text');
            app.FFgain_3.Editable = 'off';
            app.FFgain_3.FontSize = 18;
            app.FFgain_3.FontWeight = 'bold';
            app.FFgain_3.Position = [591 250 70 30];

            % Create error_3
            app.error_3 = uieditfield(app.Panel_8, 'numeric');
            app.error_3.Editable = 'off';
            app.error_3.HorizontalAlignment = 'center';
            app.error_3.FontSize = 18;
            app.error_3.FontWeight = 'bold';
            app.error_3.BackgroundColor = [0.949 0.9804 0.9294];
            app.error_3.Position = [806 254 60 28];

            % Create Label_22
            app.Label_22 = uilabel(app.Panel_8);
            app.Label_22.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.Label_22.FontSize = 14;
            app.Label_22.FontWeight = 'bold';
            app.Label_22.Position = [772 258 33 22];
            app.Label_22.Text = '誤差';

            % Create Label_16
            app.Label_16 = uilabel(app.UIFigure);
            app.Label_16.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.Label_16.FontSize = 18;
            app.Label_16.FontWeight = 'bold';
            app.Label_16.Position = [21 252 50 57];
            app.Label_16.Text = '関節3';

            % Create WRITEButton
            app.WRITEButton = uibutton(app.UIFigure, 'push');
            app.WRITEButton.ButtonPushedFcn = createCallbackFcn(app, @WRITEButtonPushed, true);
            app.WRITEButton.BackgroundColor = [1 0 0];
            app.WRITEButton.FontName = 'メイリオ';
            app.WRITEButton.FontSize = 18;
            app.WRITEButton.FontWeight = 'bold';
            app.WRITEButton.FontColor = [1 1 1];
            app.WRITEButton.Enable = 'off';
            app.WRITEButton.Position = [1202 768 100 30];
            app.WRITEButton.Text = 'WRITE';

            % Create STOPButton
            app.STOPButton = uibutton(app.UIFigure, 'push');
            app.STOPButton.ButtonPushedFcn = createCallbackFcn(app, @STOPButtonPushed, true);
            app.STOPButton.BackgroundColor = [1 0 0];
            app.STOPButton.FontName = 'メイリオ';
            app.STOPButton.FontSize = 18;
            app.STOPButton.FontWeight = 'bold';
            app.STOPButton.FontColor = [1 1 1];
            app.STOPButton.Position = [1202 842 100 30];
            app.STOPButton.Text = 'STOP';

            % Create SWITCHButton
            app.SWITCHButton = uibutton(app.UIFigure, 'push');
            app.SWITCHButton.ButtonPushedFcn = createCallbackFcn(app, @SWITCHButtonPushed, true);
            app.SWITCHButton.BackgroundColor = [1 0 0];
            app.SWITCHButton.FontName = 'メイリオ';
            app.SWITCHButton.FontSize = 18;
            app.SWITCHButton.FontWeight = 'bold';
            app.SWITCHButton.FontColor = [1 1 1];
            app.SWITCHButton.Enable = 'off';
            app.SWITCHButton.Position = [1323 842 100 30];
            app.SWITCHButton.Text = 'SWITCH';

            % Create time_approval
            app.time_approval = uieditfield(app.UIFigure, 'numeric');
            app.time_approval.HorizontalAlignment = 'center';
            app.time_approval.FontSize = 22;
            app.time_approval.Position = [984 30 157 43];

            % Create time_switching
            app.time_switching = uieditfield(app.UIFigure, 'numeric');
            app.time_switching.HorizontalAlignment = 'center';
            app.time_switching.FontSize = 22;
            app.time_switching.Position = [1202 30 153 43];

            % Create ArduinomsLabel_2
            app.ArduinomsLabel_2 = uilabel(app.UIFigure);
            app.ArduinomsLabel_2.HorizontalAlignment = 'center';
            app.ArduinomsLabel_2.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.ArduinomsLabel_2.FontSize = 14;
            app.ArduinomsLabel_2.FontWeight = 'bold';
            app.ArduinomsLabel_2.Position = [987 76 89 22];
            app.ArduinomsLabel_2.Text = '切替許可時間';

            % Create ArduinomsLabel_3
            app.ArduinomsLabel_3 = uilabel(app.UIFigure);
            app.ArduinomsLabel_3.HorizontalAlignment = 'center';
            app.ArduinomsLabel_3.FontName = 'HG丸ｺﾞｼｯｸM-PRO';
            app.ArduinomsLabel_3.FontSize = 14;
            app.ArduinomsLabel_3.FontWeight = 'bold';
            app.ArduinomsLabel_3.Position = [1205 76 89 22];
            app.ArduinomsLabel_3.Text = '切替実行時間';

            % Create ButtonGroup
            app.ButtonGroup = uibuttongroup(app.UIFigure);
            app.ButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ButtonGroupSelectionChanged, true);
            app.ButtonGroup.Title = 'モード選択';
            app.ButtonGroup.FontWeight = 'bold';
            app.ButtonGroup.Position = [919 757 146 121];

            % Create default
            app.default = uiradiobutton(app.ButtonGroup);
            app.default.Text = 'デフォルト';
            app.default.FontSize = 18;
            app.default.Position = [11 67 112 22];
            app.default.Value = true;

            % Create directedVoltageMode
            app.directedVoltageMode = uiradiobutton(app.ButtonGroup);
            app.directedVoltageMode.Text = '指令電圧';
            app.directedVoltageMode.FontSize = 18;
            app.directedVoltageMode.Position = [11 40 94 22];

            % Create jointAngleMode
            app.jointAngleMode = uiradiobutton(app.ButtonGroup);
            app.jointAngleMode.Text = '関節角度';
            app.jointAngleMode.FontSize = 18;
            app.jointAngleMode.Position = [11 13 94 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SerialDataReceiveApp_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end