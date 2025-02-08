package slogctx

import "log/slog"

type Namespace struct {
	HandlerWrapFuncs
}

func NewNamespace() *Namespace {
	return &Namespace{}
}

func (f *Namespace) RegisterHandlerWrapFunc(fn HandlerWrapFunc) {
	f.HandlerWrapFuncs = append(f.HandlerWrapFuncs, fn)
}

func (f *Namespace) RegisterHandlerPrepareFunc(fn HandlePrepareFunc) {
	f.RegisterHandleFuncWrapFunc(Prepare(fn))
}

func (f *Namespace) RegisterHandleFuncWrapFunc(fn SlogHandleConv) {
	f.RegisterHandlerWrapFunc(NewWrapFunc(fn))
}

func (f *Namespace) Register(fn HandlePrepareFunc) {
	f.RegisterHandlerPrepareFunc(fn)
}

func NewWrapFunc(fn SlogHandleConv) HandlerWrapFunc {
	return func(h slog.Handler) slog.Handler {
		handle := fn(h.Handle)
		return &wrapper{Handler: h, handle: handle}
	}
}
