local bit = {}

function bit.blshift(n, bits)
  return bit32.lshift(n,bits)
end

function bit.brshift(n, bits)
  return bit32.arshift(n,bits)
end

function bit.blogic_rshift(n, bits)
  return bit32.rshift(n,bits)
end

function bit.bxor(m, n)
  return bit32.bxor(m,n)
end

function bit.bor(m, n)
  return bit32.bor(m,n)
end

function bit.band(m, n)
  return bit32.band(m,n)
end

function bit.bnot(n)
  return bit32.bnot(n)
end

return bit