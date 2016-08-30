
ffi.cdef([[
void *compile_tcc(const char *str);
void delete_tcc(void *tcc);
void *getsymbol_tcc(void *tcc, const char *str);
]])

function cc(fn, proto, c_code)
    local tcc_context = ffi.C.compile_tcc(c_code)
    func = ffi.C.getsymbol_tcc(compiled, fn)
    func = ffi.cast(proto, func)
    return func    
end
