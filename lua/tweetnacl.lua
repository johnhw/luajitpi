ffi.cdef([[
extern int crypto_auth_hmacsha512256_tweet(unsigned char *,const unsigned char *,unsigned long long,const unsigned char *);
extern int crypto_auth_hmacsha512256_tweet_verify(const unsigned char *,const unsigned char *,unsigned long long,const unsigned char *);
extern int crypto_box_curve25519xsalsa20poly1305_tweet(unsigned char *,const unsigned char *,unsigned long long,const unsigned char *,const unsigned char *,const unsigned char *);
extern int crypto_box_curve25519xsalsa20poly1305_tweet_open(unsigned char *,const unsigned char *,unsigned long long,const unsigned char *,const unsigned char *,const unsigned char *);
extern int crypto_box_curve25519xsalsa20poly1305_tweet_keypair(unsigned char *,unsigned char *);
extern int crypto_box_curve25519xsalsa20poly1305_tweet_beforenm(unsigned char *,const unsigned char *,const unsigned char *);
extern int crypto_box_curve25519xsalsa20poly1305_tweet_afternm(unsigned char *,const unsigned char *,unsigned long long,const unsigned char *,const unsigned char *);
extern int crypto_box_curve25519xsalsa20poly1305_tweet_open_afternm(unsigned char *,const unsigned char *,unsigned long long,const unsigned char *,const unsigned char *);
extern int crypto_core_salsa20_tweet(unsigned char *,const unsigned char *,const unsigned char *,const unsigned char *);
extern int crypto_core_hsalsa20_tweet(unsigned char *,const unsigned char *,const unsigned char *,const unsigned char *);
extern int crypto_hashblocks_sha512_tweet(unsigned char *,const unsigned char *,unsigned long long);
extern int crypto_hashblocks_sha256_tweet(unsigned char *,const unsigned char *,unsigned long long);
extern int crypto_hash_sha512_tweet(unsigned char *,const unsigned char *,unsigned long long);
extern int crypto_hash_sha256_tweet(unsigned char *,const unsigned char *,unsigned long long);
extern int crypto_onetimeauth_poly1305_tweet(unsigned char *,const unsigned char *,unsigned long long,const unsigned char *);
extern int crypto_onetimeauth_poly1305_tweet_verify(const unsigned char *,const unsigned char *,unsigned long long,const unsigned char *);
extern int crypto_scalarmult_curve25519_tweet(unsigned char *,const unsigned char *,const unsigned char *);
extern int crypto_scalarmult_curve25519_tweet_base(unsigned char *,const unsigned char *);
extern int crypto_secretbox_xsalsa20poly1305_tweet(unsigned char *,const unsigned char *,unsigned long long,const unsigned char *,const unsigned char *);
extern int crypto_secretbox_xsalsa20poly1305_tweet_open(unsigned char *,const unsigned char *,unsigned long long,const unsigned char *,const unsigned char *);
extern int crypto_sign_ed25519_tweet(unsigned char *,unsigned long long *,const unsigned char *,unsigned long long,const unsigned char *);
extern int crypto_sign_ed25519_tweet_open(unsigned char *,unsigned long long *,const unsigned char *,unsigned long long,const unsigned char *);
extern int crypto_sign_ed25519_tweet_keypair(unsigned char *,unsigned char *);
extern int crypto_stream_xsalsa20_tweet(unsigned char *,unsigned long long,const unsigned char *,const unsigned char *);
extern int crypto_stream_xsalsa20_tweet_xor(unsigned char *,const unsigned char *,unsigned long long,const unsigned char *,const unsigned char *);
extern int crypto_stream_salsa20_tweet(unsigned char *,unsigned long long,const unsigned char *,const unsigned char *);
extern int crypto_stream_salsa20_tweet_xor(unsigned char *,const unsigned char *,unsigned long long,const unsigned char *,const unsigned char *);
extern int crypto_verify_16_tweet(const unsigned char *,const unsigned char *);
extern int crypto_verify_32_tweet(const unsigned char *,const unsigned char *);
]])

local crypto_core_hsalsa20_tweet_OUTPUTBYTES=32
local crypto_core_hsalsa20_tweet_INPUTBYTES=16
local crypto_core_hsalsa20_tweet_KEYBYTES=32
local crypto_core_hsalsa20_tweet_CONSTBYTES=16

-- entropy pool
local _entropy_pool = ffi.new("uint32_t[256]")

local function update_entropy()
    local a = raw_read_rng()
    local a1,a2,a3,a4 = split32(a)
    _entropy_pool[a1] = bit.bxor(raw_read_rng(), _entropy_pool[a1])
    _entropy_pool[a2] = bit.bxor(raw_read_rng(), _entropy_pool[a2])
    _entropy_pool[a3] = bit.bxor(raw_read_rng(), _entropy_pool[a3])
    _entropy_pool[a4] = bit.bxor(raw_read_rng(), _entropy_pool[a4])
end

local function fill_entropy()
    for i=1,256 do
        _entropy_pool[i] = bit.bxor(raw_read_rng(), _entropy_pool[i])
    end
end

local obytes = 32
local ibytes = 16
local kbytes = 32
local nbytes = 24
