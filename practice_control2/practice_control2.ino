#define joint_num 3//あいうえお
//あかさたな
//ピン指定
const int yled = 46;
const int rled = 48;
const int ledLoop_Number = 3;

//モータ
const int rotateDirection_pinNumber[joint_num] = { 32, 30, 36 };

//配線によるモータの回転方向 角度が発散する様に挙動したらここの正負をcheck
const double rotateDirection[joint_num] = { 1, 1, -1 };  
const int motorPWM_pinNumber[joint_num] = { 3, 2, 5 };
const int angleWidth_variation = 5;

//本番用に設定済み
const int readPotentio_pinNumber[joint_num] = { 0, 1, 2 };

//ポテンショデータ
const int angle0deg_potentioNumeric[joint_num] = { 579, 460, 605 };
//ポテンショの読む方向
const int readAngleDirection[joint_num] = { -1, 1, 1 };
//90°回転したときのポテンショメータの変化幅
const double Width90deg_potentioNumeric = 337;


//モータドライバ(MD)に出力されるデューティー比
double Duty2MD[joint_num];

int angleRead_potentioNumeric[joint_num];

//angle_previousは今回使わない
double angle[joint_num];
const int NUM_ANGLE_PREVIOUS = 10;
double angle_previous[joint_num];
double angle_previous_array[joint_num][NUM_ANGLE_PREVIOUS];
int pointer_angle_previous = 0;
double angle_target[joint_num] = { 35.0, 20.0, -35.0 };

//PID制御における制御偏差(deviation)とその微分値、積分値
double deviation[joint_num];
double deviation_previous[joint_num];
double deviation_INT[joint_num];
double deviation_DIFF[joint_num];

//移動平均フィルタ
bool isMovingfilterValidated = true;
const int stockRotation_sampleTerm = 10;
int stockRotation_count = 0;
double angle_stock[joint_num][stockRotation_sampleTerm];
double angle_samplesummed[joint_num] = { 0.0, 0.0, 0.0 };


long time_data;
long time_start = 0;
long pre_log_time = 0;
long log_interval = 30;

double I_sw[joint_num] = { 1, 1, 1 };

double t = 0.0;
double dt_ms = 1.0;
double dt_us = 1.0;
char key;
int flag = 0;

//制御開始タイミングを管理するフラグ
bool HasControlStarted = false;

//デューティー比最大値
const double val_max[joint_num] = { 30, 50, 50 };

const double angle_max = 40;

//アンチワインドアップ　今回はいじらない
boolean anti_windup = false;
double anti_windup_th = 0.5;

//位置PIDゲイン
//constで固定
double kp[joint_num] = { 3.0, 0.5, 1.1 };
const double kd[joint_num] = { 0.0, 0.0006, 20.0 };
//const double kd[joint_num] = { 0.0, 0.0, 0.0 };
const double ki[joint_num] = { 0.0015, 0.0002, 0.0002 };
const double kf_plus[joint_num] = { 0.0, -0.5, -0.7 };
const double kf_minus[joint_num] = { 0.0, 0.5, 0.7 };

//ゲインを有効数字何桁まで表示する？
const int sigFigure_Gaindisplay = 4;


bool over_limit = false;

//コマンドリスト
/*
No.0 s:Start 通信のスタート
No.1 f:Form デフォルトで規定するモジュール位置
No.2 r:Reset モジュール位置を1直線に戻す
No.3 t:関節1を+5°
No.4 y:関節1を-5°
No.5 g:関節2を+5°
No.6 h:関節2を-5°
No.7 b:関節3を+5°
No.8 n:関節3を-5°
*/

//visualizeアプリとの通信頻度の指定
int plot_count = 0;
//10ループに1回シリアル通信でデータを送る
const int sendInterval_number = 10;

double time_present_ms = 1.0;
double time_present_us = 1.0;
double time_previous_ms = 0.0;
double time_previous_us = 0.0;



void setup() {
  // put your setup code here, to run once

  Serial.begin(115200);

  pinMode(yled, OUTPUT);
  pinMode(rled, OUTPUT);

  //触れると危険なものはconstで宣言
  for (int i = 0; i < ledLoop_Number; i++) {
    digitalWrite(rled, HIGH);
    delay(500);
    digitalWrite(rled, LOW);
    delay(500);
  }
  flag = 0;
  for (int i = 0; i < joint_num; i++) {
    pinMode(rotateDirection_pinNumber[i], OUTPUT);
    pinMode(motorPWM_pinNumber[i], OUTPUT);

    analogWrite(motorPWM_pinNumber[i], 0);
    analogWrite(rotateDirection_pinNumber[i], 0);
  }

  //モータドライバに入力する4番目のピンもLOWにしないとMDにエラーが走る
  pinMode(34, OUTPUT);
  pinMode(4, OUTPUT);
  analogWrite(34, 0);
  analogWrite(4, 0);

  for (int i = 0; i < joint_num; i++) {
    for (int j = 0; j < stockRotation_sampleTerm; j++) {
      angle_stock[i][j] = 0.0;
    }
  }
  for (int i = 0; i < joint_num; i++) {
    for (int j = 0; j < NUM_ANGLE_PREVIOUS; j++) {
      angle_previous_array[i][j] = 0.0;
    }
  }
}

void loop() {
  if (HasControlStarted == false) {
    if (Serial.available() > 0) {
      key = Serial.read();
      if (key == 's') {
        HasControlStarted = true;
        time_start = millis();
      } else if (key == 'g') {
        for (int i = 0; i < joint_num; i++) {
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
    digitalWrite(rled, HIGH);

    t = (double)(millis() - time_start);
    //キー入力
    if (Serial.available() > 0) {
      key = Serial.read();

      if (key == 'f') {
        angle_target[0] = -40;
        angle_target[1] = 30;
        angle_target[2] = 30;
        flag = 1;
        t = 0;
      } else if (key == 'r') {
        angle_target[0] = 0;
        angle_target[1] = 0;
        angle_target[2] = 0;
        t = 0;
      }


      else {
        switch (key) {
          case 't':
            angle_target[0] += angleWidth_variation;
            break;

          case 'g':
            angle_target[1] += angleWidth_variation;
            break;

          case 'b':
            angle_target[2] += angleWidth_variation;
            break;

          case 'y':
            angle_target[0] -= angleWidth_variation;
            break;

          case 'h':
            angle_target[1] -= angleWidth_variation;
            break;

          case 'n':
            angle_target[2] -= angleWidth_variation;
            break;

          default:
            break;
        }
      }
      //目的角の最大値設定
      //コマンドがきたときだけ走らせる
      for (int i = 0; i < joint_num; i++) {
        if (angle_target[i] > angle_max) {
          angle_target[i] = angle_max;
        }
        if (angle_target[i] < -angle_max) {
          angle_target[i] = -angle_max;
        }
      }
    }

    for (int i = 0; i < joint_num; i++) {

      //関節角度取得
      //データ保存
      angleRead_potentioNumeric[i] = analogRead(readPotentio_pinNumber[i]);
      angle[i] = (double)((angleRead_potentioNumeric[i] - angle0deg_potentioNumeric[i]) * readAngleDirection[i]) * 90 / Width90deg_potentioNumeric;

      //変数名validateは誤解を生む
      if (isMovingfilterValidated) {
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

      //msecだと分かるような変数名
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
      if (pointer == NUM_ANGLE_PREVIOUS){
        pointer = 0;
      }
      deviation_DIFF[i] = (angle_previous_array[i][pointer] - angle[i]) / (dt_us / 1000.0d);

      deviation_previous[i] = deviation[i];
      Duty2MD[i] = deviation[i] * kp[i] + deviation_DIFF[i] * kd[i] + deviation_INT[i] * ki[i];

      if (angle_target[i] >= 0) {
        Duty2MD[i] += angle_target[i] * kf_plus[i]*rotateDirection[i];
      }
      if (angle_target[i] < 0) {
        Duty2MD[i] += angle_target[i] * kf_minus[i]*rotateDirection[i];
      }
      //回転方向指定
      if (Duty2MD[i] * rotateDirection[i] < 0) {
        digitalWrite(rotateDirection_pinNumber[i], LOW);
      } else {
        digitalWrite(rotateDirection_pinNumber[i], HIGH);
      }
      I_sw[i] = 1;
      if (Duty2MD[i] > val_max[i]) {
        Duty2MD[i] = val_max[i];
        I_sw[i] = 0;
      }
      if (Duty2MD[i] < -val_max[i]) {
        Duty2MD[i] = -val_max[i];
        I_sw[i] = 0;
      }

      //pwm書き込み
      analogWrite(motorPWM_pinNumber[i], abs(Duty2MD[i]));
      //4番目
      analogWrite(4, 30);
      angle_previous[i] = angle[i];
      
      pointer_angle_previous += 1;
      if (pointer_angle_previous >= NUM_ANGLE_PREVIOUS) {
        pointer_angle_previous = 0;
      }
      angle_previous_array[i][pointer_angle_previous] = angle[i];
    }
    /*if (millis() - pre_log_time > log_interval) {*/
    if (plot_count == sendInterval_number - 1) {
      //データ出力
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
      Serial.print(Duty2MD[0]);
      Serial.print(", Duty1:");
      Serial.print(Duty2MD[1]);
      Serial.print(", Duty2:");
      Serial.print(Duty2MD[2]);
      Serial.print(", dt:");
      Serial.println(dt_ms);
      plot_count = 0;
    }
    plot_count += 1;

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