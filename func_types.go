package slogw

import (
	"context"
	"log/slog"
)

type HandleFunc = func(context.Context, slog.Record) error
type HandleFuncWrapFunc = func(HandleFunc) HandleFunc

type HandlePrepareFunc = func(context.Context, slog.Record) slog.Record

func Prepare(prepare HandlePrepareFunc) HandleFuncWrapFunc {
	return func(fn HandleFunc) HandleFunc {
		return func(ctx context.Context, rec slog.Record) error {
			return fn(ctx, prepare(ctx, rec))
		}
	}
}

type HandlerWrapFunc = func(slog.Handler) slog.Handler

type HandlerWrapFuncs []HandlerWrapFunc

func (fns HandlerWrapFuncs) Wrap(h slog.Handler) slog.Handler {
	for i := len(fns) - 1; i >= 0; i-- {
		h = fns[i](h)
	}
	return h
}

func (fns HandlerWrapFuncs) New(h slog.Handler) *slog.Logger {
	return slog.New(fns.Wrap(h))
}
