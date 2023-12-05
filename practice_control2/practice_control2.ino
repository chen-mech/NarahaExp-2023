const int NUM_JOINT = 3;  //関節3つで実験

//LED関連
const int blueled = 48;
const int redled = 50;
const int ledLoop_Times = 3;

//アナログスイッチ関連
const int switch1_pinNumber = 57;
const int switch2_pinNumber = 56;

//モータ関連
const int rotateDirection_pinNumber[NUM_JOINT] = { 32, 30, 36 };
const int rotateDirection[NUM_JOINT] = { 1, 1, -1 };  //角度が発散する様に挙動したらここの正負を確認

//ポテンショメータ関連
const int readPotentio_pinNumber[NUM_JOINT] = { 0, 1, 4 };
const int readAngleDirection[NUM_JOINT] = { -1, 1, 1 };//角度の向きが違ったらここの正負を確認
const int angle0deg_potentioNumeric[NUM_JOINT] = { 579, 460, 605 };
const int Width90deg_potentioNumeric = 337;

//モータドライバ関連
const int motorPWM_pinNumber[NUM_JOINT] = { 3, 2, 5 };
double directedVoltage[NUM_JOINT] = {0.0, 0.0, 0.0};
const double directedVoltage_max[NUM_JOINT] = { 30.0, 50.0, 50.0 };

//角度情報
int angleRead_potentioNumeric[NUM_JOINT];
double angle[NUM_JOINT];
double angle_target[NUM_JOINT] = { 35.0, 20.0, -35.0 };
const double angle_target_max = 40.0;
const double WIDTH_ANGLE_VARIATION = 5.0;

//位置PID+FFゲイン
const double kp[NUM_JOINT] = { 3.0, 0.5, 1.1 };
const double kd[NUM_JOINT] = { 0.0, 0.0006, 20.0 };
const double ki[NUM_JOINT] = { 0.0015, 0.0002, 0.0002 };
const double kf_plus[NUM_JOINT] = { 0.0, -0.5, -0.7 };
const double kf_minus[NUM_JOINT] = { 0.0, 0.5, 0.7 };
const int sigFigure_Gaindisplay = 4;

//PID制御における制御偏差(deviation)
double deviation[NUM_JOINT];
double deviation_previous[NUM_JOINT];
double deviation_INT[NUM_JOINT];
double deviation_DIFF[NUM_JOINT];

//D制御の偏差微分計算
const int NUM_ANGLE_PREVIOUS = 10;
double angle_previous[NUM_JOINT];
double angle_previous_array[NUM_JOINT][NUM_ANGLE_PREVIOUS];
int pointer_angle_previous = 0;

//移動平均フィルタ
bool isMovingfilterEnabled = true;
const int stockRotation_sampleTerm = 10;
int stockRotation_count = 0;
double angle_stock[NUM_JOINT][stockRotation_sampleTerm];
double angle_samplesummed[NUM_JOINT] = { 0.0, 0.0, 0.0 };

//平均絶対偏差
bool switchingMode = false; //trueなら指令電圧に、falseなら関節角度に切り替えのトリガがある
int counter_trigger_stock[NUM_JOINT] = {0, 0, 0};
const int NUM_TRIGGER_STOCK = 15;
double stock_trigger_array[NUM_JOINT][NUM_TRIGGER_STOCK];
double mean_valueStock[NUM_JOINT] = {0.0, 0.0, 0.0};
double error_valueStock[NUM_JOINT] = {0.0, 0.0, 0.0};
double error_valueStock_forcommunicate[NUM_JOINT] = {0.0, 0.0, 0.0};
int counter_error_stock[NUM_JOINT] = {0, 0, 0};
const int NUM_ERROR_STOCK = 10;
double stock_error_array[NUM_JOINT][NUM_ERROR_STOCK];


//切替機構
bool IsWireSwitched = false;
const int NUM_DIRECTED_VOLTAGE = 10;
int directedVoltage_diff_count[NUM_JOINT] = {0, 0, 0};
double directedVoltage_previous[NUM_JOINT] = {0.0, 0.0, 0.0};
double directedVoltage_diff[NUM_JOINT] = {0.0, 0.0, 0.0};
double directedVoltage_diff_aray[NUM_JOINT][NUM_DIRECTED_VOLTAGE];
const double thresholdVoltage[NUM_JOINT] = {0.1 , 0.1, 0.1};//TODO 
const double thresholdAngle[NUM_JOINT] = {0.1, 0.5, 0.6}; //単位はdeg
bool IsSwitchingEnabled[NUM_JOINT] = {false, false, false};

//周期取得
int time_start_msec = 0;
double t = 0.0;
double dt_ms = 1.0;
double dt_us = 1.0;
double time_present_ms = 1.0;
double time_present_us = 1.0;
double time_previous_ms = 0.0;
double time_previous_us = 0.0;

//アンチワインドアップ
double I_sw[NUM_JOINT] = { 1, 1, 1 };
bool anti_windup = false;
double anti_windup_th = 0.5;

//シリアル通信関連
bool HasControlStarted = false;
const int NUM_SEND_INTERVAL = 2;
int pointer_sendcount = 0;
char ch_received;

/*
コマンドリスト
No.0 s:Start 通信のスタート
No.1 f:Format デフォルトで規定するモジュール位置
No.2 r:Reset モジュール位置を1直線に戻す
No.3 t:関節1を+5°
No.4 y:関節1を-5°
No.5 g:関節2を+5°
No.6 h:関節2を-5°
No.7 b:関節3を+5°
No.8 n:関節3を-5°
No.9 w:切り替えの指示
*/

void setup() {
  Serial.begin(115200);

  pinMode(blueled, OUTPUT);
  pinMode(redled, OUTPUT);

  digitalWrite(redled, HIGH);
  for (int i = 0; i < ledLoop_Times; i++) {
    digitalWrite(blueled, LOW);
    delay(500);
    digitalWrite(blueled, HIGH);
    delay(500);
  }
  pinMode(switch1_pinNumber, OUTPUT);
  pinMode(switch2_pinNumber, OUTPUT); 
  digitalWrite(switch1_pinNumber, HIGH);
  digitalWrite(switch2_pinNumber, LOW); 

  for (int i = 0; i < NUM_JOINT; i++) {
    pinMode(rotateDirection_pinNumber[i], OUTPUT);
    pinMode(motorPWM_pinNumber[i], OUTPUT);

    analogWrite(motorPWM_pinNumber[i], 0);
    analogWrite(rotateDirection_pinNumber[i], 0);
  }

  //モータドライバに入力する4番目のピンもLOWにしないとエラーが走る
  pinMode(34, OUTPUT);
  pinMode(4, OUTPUT);
  analogWrite(34, 0);
  analogWrite(4, 0);

  for (int i = 0; i < NUM_JOINT; i++) {
    for (int j = 0; j < stockRotation_sampleTerm; j++) {
      angle_stock[i][j] = 0.0;
    }
  }

  for (int i = 0; i < NUM_JOINT; i++) {
    for (int j = 0; j < NUM_ANGLE_PREVIOUS; j++) {
      angle_previous_array[i][j] = 0.0;
    }
  }

  for (int i = 0; i < NUM_JOINT; i++) {
    for (int j = 0; j < NUM_DIRECTED_VOLTAGE; j++) {
      directedVoltage_diff_aray[i][j] = 0.0;
    }
  }

  for (int i = 0; i < NUM_JOINT; i++) {
    for (int j = 0; j < NUM_TRIGGER_STOCK; j++) {
      stock_trigger_array[i][j] = 0.0;
    }
  }

  for (int i = 0; i < NUM_JOINT; i++) {
    for (int j = 0; j < NUM_ERROR_STOCK; j++) {
      stock_error_array[i][j] = 0.0;
    }
  }
}

void loop() {
  if (HasControlStarted == false) {
    if (Serial.available() > 0) {
      ch_received = Serial.read();
      if (ch_received == 's') {
        HasControlStarted = true;
        digitalWrite(blueled, LOW);
        time_start_msec = millis();
      } else if (ch_received == 'g') {
        for (int i = 0; i < NUM_JOINT; i++) {
          Serial.print(",kp:");
          Serial.print(kp[i], sigFigure_Gaindisplay);
          Serial.print(",kd:");
          Serial.print(kd[i], sigFigure_Gaindisplay);
          Serial.print(",ki:");
          Serial.print(ki[i], sigFigure_Gaindisplay);
          Serial.print(",kf:");
          Serial.print(kf_plus[i], sigFigure_Gaindisplay);
        }
        Serial.println("");
      }
    }
    delay(1);
  }


  else {

    t = (double)(millis() - time_start_msec);
    //キー入力
    if (Serial.available() > 0) {
      ch_received = Serial.read();

      if (ch_received == 'f') {
        angle_target[0] = -40;
        angle_target[1] = 30;
        angle_target[2] = 30;
        t = 0;
      } else if (ch_received == 'r') {
        angle_target[0] = 0;
        angle_target[1] = 0;
        angle_target[2] = 0;
        t = 0;
      }


      else {
        switch (ch_received) {
          case 't':
            angle_target[0] += WIDTH_ANGLE_VARIATION;
            break;

          case 'g':
            angle_target[1] += WIDTH_ANGLE_VARIATION;
            break;

          case 'b':
            angle_target[2] += WIDTH_ANGLE_VARIATION;
            break;

          case 'y':
            angle_target[0] -= WIDTH_ANGLE_VARIATION;
            break;

          case 'h':
            angle_target[1] -= WIDTH_ANGLE_VARIATION;
            break;

          case 'n':
            angle_target[2] -= WIDTH_ANGLE_VARIATION;
            break;

          case 'w':
            IsWireSwitched = true;
            break;

          default:
            break;
        }
      }
      //目的角の最大値設定
      //コマンドがきたときだけ走らせる
      for (int i = 0; i < NUM_JOINT; i++) {
        if (angle_target[i] > angle_target_max) {
          angle_target[i] = angle_target_max;
        }
        if (angle_target[i] < -angle_target_max) {
          angle_target[i] = -angle_target_max;
        }
      }
    }

    for (int i = 0; i < NUM_JOINT; i++) {

      //角度情報取得
      angleRead_potentioNumeric[i] = analogRead(readPotentio_pinNumber[i]);
      angle[i] = (double)((angleRead_potentioNumeric[i] - angle0deg_potentioNumeric[i]) * readAngleDirection[i]) * 90 / Width90deg_potentioNumeric;

      
      if (isMovingfilterEnabled) {
        stockRotation_count++;
        if (stockRotation_count >= stockRotation_sampleTerm) {
          stockRotation_count = 0;
        }
        angle_stock[i][stockRotation_count] = angle[i];

        for (int j = 0; j < stockRotation_sampleTerm; j++) {
          angle_samplesummed[i] += angle_stock[i][j];
        }

        angle[i] = angle_samplesummed[i] / double(stockRotation_sampleTerm);
        angle_samplesummed[i] = 0.0;
      }


      if (t < 500) {
        angle[i] = angle_target[i];
      }

      //アンチワインドアップ無効化
      if (!anti_windup) {
        I_sw[i] = 1;
      }



      deviation[i] = angle_target[i] - angle[i];
      //deviation_DIFF[i] = (deviation_previous[i] - deviation[i]) / dt_ms;
      deviation_INT[i] += deviation[i] * dt_ms;

      int pointer = pointer_angle_previous + 1;
      if (pointer == NUM_ANGLE_PREVIOUS) {
        pointer = 0;
      }
      deviation_DIFF[i] = (angle_previous_array[i][pointer] - angle[i]) / (dt_us / 1000.0d);

      deviation_previous[i] = deviation[i];

      directedVoltage_previous[i] = directedVoltage[i]; 
      directedVoltage[i] = deviation[i] * kp[i] + deviation_DIFF[i] * kd[i] + deviation_INT[i] * ki[i];
      
      if (angle_target[i] >= 0) {
        directedVoltage[i] += angle_target[i] * kf_plus[i] * rotateDirection[i]; 
      }
      if (angle_target[i] < 0) {
        directedVoltage[i] += angle_target[i] * kf_minus[i] * rotateDirection[i];
      }

      //回転方向指定
      if (directedVoltage[i] * rotateDirection[i] < 0) {
        digitalWrite(rotateDirection_pinNumber[i], LOW);
      } else {
        digitalWrite(rotateDirection_pinNumber[i], HIGH);
      }
      I_sw[i] = 1;
      if (directedVoltage[i] > directedVoltage_max[i]) {
        directedVoltage[i] = directedVoltage_max[i];
        I_sw[i] = 0;
      }
      if (directedVoltage[i] < -directedVoltage_max[i]) {
        directedVoltage[i] = -directedVoltage_max[i];
        I_sw[i] = 0;
      }

      // //指令電圧偏差を格納する配列を作成
      // directedVoltage_diff[i] = directedVoltage[i] - directedVoltage_previous[i];
      // directedVoltage_diff_count[i] ++;
      // if(directedVoltage_diff_count[i] >= NUM_DIRECTED_VOLTAGE){
      //   directedVoltage_diff_count[i] = 0;
      // }
      // directedVoltage_diff_aray[i][directedVoltage_diff_count[i]] = directedVoltage_diff[i];
      
      

      //平均絶対誤差を格納する配列を作成
      counter_trigger_stock[i] ++;
      if(counter_trigger_stock[i] >= NUM_TRIGGER_STOCK){
        counter_trigger_stock[i] = 0;
      }
      if(switchingMode == true){
        stock_trigger_array[i][counter_trigger_stock[i]] = directedVoltage[i];
      }
      else{
        stock_trigger_array[i][counter_trigger_stock[i]] = angle[i];  
      }

      for (int j = 0; j < NUM_TRIGGER_STOCK; j++){
        mean_valueStock[i] += stock_trigger_array[i][j];
      }
      mean_valueStock[i] = mean_valueStock[i] / NUM_TRIGGER_STOCK;

      for (int j = 0; j < NUM_TRIGGER_STOCK; j++){
        error_valueStock[i] += abs(stock_trigger_array[i][j] - mean_valueStock[i]);
      }
      error_valueStock[i] = error_valueStock[i] / NUM_TRIGGER_STOCK;

      if(counter_error_stock[i] >= NUM_ERROR_STOCK){
        counter_error_stock[i] = 0;
      }
      stock_error_array[i][counter_trigger_stock[i]] = error_valueStock[i];
      error_valueStock_forcommunicate[i] = error_valueStock[i];
      error_valueStock[i] = 0.0;
      mean_valueStock[i] = 0.0;
       

      //スイッチICの切り替え条件
      if(IsWireSwitched == true){
        IsSwitchingEnabled[i] = true;
        if(switchingMode == true){
          for(int j = 0; j<NUM_ERROR_STOCK; j++ ){
            if(stock_error_array[i][j] > thresholdVoltage[i]){
              IsSwitchingEnabled[i] = false;
              break;
            }
          }
        }
        else{
          for(int j = 0; j<NUM_ERROR_STOCK; j++ ){
            if(stock_error_array[i][j] > thresholdAngle[i]){  
              IsSwitchingEnabled[i] = false;
              break;
            }
          }
        }
      }

      //pwm書き込み
      analogWrite(motorPWM_pinNumber[i], abs(directedVoltage[i]));
      //4番目
      analogWrite(4, 30);
      angle_previous[i] = angle[i];

      pointer_angle_previous += 1;
      if (pointer_angle_previous >= NUM_ANGLE_PREVIOUS) {
        pointer_angle_previous = 0;
      }
      angle_previous_array[i][pointer_angle_previous] = angle[i];
    }

    if(IsWireSwitched == true && IsSwitchingEnabled[0] == true && IsSwitchingEnabled[1] == true && IsSwitchingEnabled[2] == true){
      digitalWrite(switch1_pinNumber, LOW);
      digitalWrite(switch2_pinNumber, HIGH); 
      digitalWrite(redled, LOW);
      IsWireSwitched = false;
    }

    if (pointer_sendcount == NUM_SEND_INTERVAL - 1) {
      Serial.print("a0:");
      Serial.print(angle[0]);
      Serial.print(",ta0:");
      Serial.print(angle_target[0]);
      Serial.print(",a1:");
      Serial.print(angle[1]);
      Serial.print(",ta1:");
      Serial.print(angle_target[1]);
      Serial.print(",a2:");
      Serial.print(angle[2]);
      Serial.print(",ta2:");
      Serial.print(angle_target[2]);
      Serial.print(",t:");
      Serial.print(t);
      Serial.print(",devi[0]:");
      Serial.print(deviation[0]);
      Serial.print(",devi[1]:");
      Serial.print(deviation[1]);
      Serial.print(",devi[2]:");
      Serial.print(deviation[2]);
      Serial.print(",DIFF[0]:");
      Serial.print(deviation_DIFF[0]);
      Serial.print(",DIFF[1]:");
      Serial.print(deviation_DIFF[1]);
      Serial.print(",DIFF[2]:");
      Serial.print(deviation_DIFF[2]);
      Serial.print(",INT[0]:");
      Serial.print(deviation_INT[0]);
      Serial.print(",INT[1]:");
      Serial.print(deviation_INT[1]);
      Serial.print(",INT[2]:");
      Serial.print(deviation_INT[2]);
      Serial.print(", Duty0:");
      Serial.print(directedVoltage[0]);
      Serial.print(", Duty1:");
      Serial.print(directedVoltage[1]);
      Serial.print(", Duty2:");
      Serial.print(directedVoltage[2]);
      Serial.print(", error0:");
      Serial.print(error_valueStock_forcommunicate[0]);
      Serial.print(", error1:");
      Serial.print(error_valueStock_forcommunicate[1]);
      Serial.print(", error2:");
      Serial.print(error_valueStock_forcommunicate[2]);
      Serial.print(", dt:");
      Serial.println(dt_ms);
      pointer_sendcount = 0;
    }
    pointer_sendcount += 1;

    //時間更新
    time_previous_ms = time_present_ms;
    time_previous_us = time_present_us;
    time_present_ms = millis();
    time_present_us = micros();
    dt_ms = (double)(time_present_ms - time_previous_ms);  //[ms]
    dt_us = (double)(time_present_us - time_previous_us);  //[us]
    delay(1);
  }
}


