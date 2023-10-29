package main

import (
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", logHandler)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatalf("unable to start server: %v", err)
	}
}

func logHandler(w http.ResponseWriter, r *http.Request) {
	logger, err := getCustomLogger()
	if err != nil {
		panic(err)
	}

	defer func(logger *zap.Logger) {
		err = logger.Sync()
		if err != nil {
		}
	}(logger)

	l := logger.Sugar()

	l.Infof("Test Entry")
	l.Errorf("Test Entry")
	l.Debugf("Test Entry")
}

func getCustomLogger() (*zap.Logger, error) {
	encoderCfg := zap.NewProductionEncoderConfig()
	encoderCfg.EncodeTime = zapcore.ISO8601TimeEncoder
	encoderCfg.EncodeLevel = zapcore.CapitalLevelEncoder
	encoderCfg.TimeKey = "timestamp"
	encoderCfg.LevelKey = "severity"
	encoderCfg.CallerKey = "caller"
	encoderCfg.MessageKey = "message"
	encoderCfg.StacktraceKey = "trace"

	core := zapcore.NewCore(
		zapcore.NewConsoleEncoder(encoderCfg),
		zapcore.Lock(os.Stdout),
		zapcore.DebugLevel, // or any other desired log level like zapcore.InfoLevel
	)

	return zap.New(core, zap.AddCaller(), zap.AddStacktrace(zap.ErrorLevel)), nil
}
