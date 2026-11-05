# omnigent 0.19.1 の実行時依存 (既定の依存のみ)。
#
# 生成元: https://github.com/omnigent-ai/omnigent のタグ v0.19.1 の uv.lock を
# CPython 3.14 / x86_64-linux で解決した結果。cp314 の manylinux wheel が
# ある依存は wheel を、無い物は sdist を使う。
#
# 更新手順は docs/omnigent.md「パッケージの組み立て」を参照。
# cryptography は Rust ビルドが重いためここには入れず、default.nix 側で
# nixpkgs のビルド済みパッケージを使う。
{ spec }:
{
  "alembic" =
    spec "1.18.4"
      "https://files.pythonhosted.org/packages/94/13/8b084e0f2efb0275a1d534838844926f798bd766566b1375174e2448cd31/alembic-1.18.4.tar.gz"
      "sha256-y24f2EthdKuNuyMp+G1jG6lVndeN9VC1eATWB2cs7bw=";
  "annotated-doc" =
    spec "0.0.4"
      "https://files.pythonhosted.org/packages/57/ba/046ceea27344560984e26a590f90bc7f4a75b06701f653222458922b558c/annotated_doc-0.0.4.tar.gz"
      "sha256-+82pbofpySrRZ8LlODnldQPs/aGIBOooECNTSFAz+qQ=";
  "annotated-types" =
    spec "0.7.0"
      "https://files.pythonhosted.org/packages/ee/67/531ea369ba64dcff5ec9c3402f9f51bf748cec26dde048a2f973a4eea7f5/annotated_types-0.7.0.tar.gz"
      "sha256-r/B8CaU6CLyM/MuchbBfGqmipvI3KNeQcjVDQINEzok=";
  "anyio" =
    spec "4.14.2"
      "https://files.pythonhosted.org/packages/61/cc/a381afa6efea9f496eff839d4a6a1aed3bfafc7b3ab4b0d1b243a12573dd/anyio-4.14.2.tar.gz"
      "sha256-z6E58+0aI+6PiKFF3bWsdgW4u/2Fkrqs1849i7QxPH8=";
  "argon2-cffi" =
    spec "25.1.0"
      "https://files.pythonhosted.org/packages/0e/89/ce5af8a7d472a67cc819d5d998aa8c82c5d860608c4db9f46f1162d7dab9/argon2_cffi-25.1.0.tar.gz"
      "sha256-aUrlzIpC9MTivyyg5k5R4joEDGpReoUHRoPTlZ4TRsE=";
  "argon2-cffi-bindings" =
    spec "25.1.0"
      "https://files.pythonhosted.org/packages/5c/2d/db8af0df73c1cf454f71b2bbe5e356b8c1f8041c979f505b3d3186e520a9/argon2_cffi_bindings-25.1.0.tar.gz"
      "sha256-uVfz5upNVdgg5A/3b0UJUoBwE9Nhpl1/KKzArL8pIp0=";
  "attrs" =
    spec "26.1.0"
      "https://files.pythonhosted.org/packages/9a/8e/82a0fe20a541c03148528be8cac2408564a6c9a0cc7e9171802bc1d26985/attrs-26.1.0.tar.gz"
      "sha256-0DzricsyKo/XBtT7kZQHN7ZkKqNpmP4TCpvJbJhe/zI=";
  "cachetools" =
    spec "7.2.1"
      "https://files.pythonhosted.org/packages/31/44/71476a5812da1ddf2c9a3efd31ae76d01480a1cf03ed13ac28aa8f2402e4/cachetools-7.2.1.tar.gz"
      "sha256-sadTcCXAar+W/MFEPklq+aP7led05w4fCvIm9z9/Lcw=";
  "cel-python" =
    spec "0.5.0"
      "https://files.pythonhosted.org/packages/61/4e/f821948a5bbd7a98a218720f831a62216f79a98e43b13d9ab2f98e37c5f8/cel_python-0.5.0.tar.gz"
      "sha256-PrCmGejfDzONBDDNoBQnp0LnfjxDOhx8Pr1AnNgExFo=";
  "certifi" =
    spec "2026.10.19"
      "https://files.pythonhosted.org/packages/a6/bd/1436c50cc46699de0230fbaacc1d1de7bfec413176099949e9d5112e88f2/certifi-2026.10.19.tar.gz"
      "sha256-A1wehVcrFBvxw6Pv8OM6jrdJF1IvJVkHX/jS/qeAoa4=";
  "cffi" =
    spec "2.0.0"
      "https://files.pythonhosted.org/packages/47/d9/d83e293854571c877a92da46fdec39158f8d7e68da75bf73581225d28e90/cffi-2.0.0-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
      "sha256-r7jbVDm4HPnJ0MgEBLYMPMnDrdk+EU3K52fxR3y1N3U=";
  "charset-normalizer" =
    spec "3.4.7"
      "https://files.pythonhosted.org/packages/47/5c/032c2d5a07fe4d4855fea851209cca2b6f03ebeb6d4e3afdb3358386a684/charset_normalizer-3.4.7-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-vWwqHHVzxkc41xZIjSzdPADjQOSDVwfY/bjcGmbvFk4=";
  "claude-agent-sdk" =
    spec "0.2.121"
      "https://files.pythonhosted.org/packages/73/9a/7b176b2afef7e4b671bf3723c2a3b09f912ee071e06c15f7f09c46d30ca2/claude_agent_sdk-0.2.121.tar.gz"
      "sha256-oA8xPru/mndW7Ic0yenDwRxTvVaxRNy9NdSxvFT6HQg=";
  "click" =
    spec "8.5.0"
      "https://files.pythonhosted.org/packages/c7/0e/7fa0ef50764b67090eca4114772a2abf8b6148198475e54c660b97caeee6/click-8.5.0.tar.gz"
      "sha256-ug0gid516gMQ4t3gMWDmyhAAmUf7laGC+bVAIbsnLjQ=";
  "distro" =
    spec "1.9.0"
      "https://files.pythonhosted.org/packages/fc/f8/98eea607f65de6527f8a2e8885fc8015d3e6f5775df186e443e0964a11c3/distro-1.9.0.tar.gz"
      "sha256-L6d8b9iUDxFu4da5Si+QsTteqNAZuYvIuv3KvN2b2+0=";
  "fastapi" =
    spec "0.136.3"
      "https://files.pythonhosted.org/packages/81/2d/ff8d91d7b564d464629a0fd50a4489c97fcb836ac230bf3a7269232a9b1f/fastapi-0.136.3.tar.gz"
      "sha256-5If66TrUCOb0dkHuTf44mGT9e+yS5UfqhJj8E/Q+g6s=";
  "filelock" =
    spec "4.1.1"
      "https://files.pythonhosted.org/packages/35/c8/1d457d9150ff948f2ce6ada7715e0eeebbe5d3b58a45271a1e222474bcd3/filelock-4.1.1.tar.gz"
      "sha256-e6CSdILFqBSwp/OR0CnM24AQ9Xbwp0wNzeGBHovEwbY=";
  "ftfy" =
    spec "6.3.1"
      "https://files.pythonhosted.org/packages/a5/d3/8650919bc3c7c6e90ee3fa7fd618bf373cbbe55dff043bd67353dbb20cd8/ftfy-6.3.1.tar.gz"
      "sha256-mzw9kPhPsmf+ZNN1oHt/iRLYF8+GAJrhNKoD4YGVBuw=";
  "google-re2" =
    spec "1.1.20251105"
      "https://files.pythonhosted.org/packages/03/be/a8def96aa4a80b233e105767d22e3de961dcde5a04f0a05cb4f3ddb4df78/google_re2-1.1.20251105-1-cp314-cp314-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-p7+qLPVdrwxcZQ5oUmuyC2HjfX865T9okwE6zByRwRY=";
  "griffelib" =
    spec "2.0.2"
      "https://files.pythonhosted.org/packages/9d/82/74f4a3310cdabfbb10da554c3a672847f1ed33c6f61dd472681ce7f1fe67/griffelib-2.0.2.tar.gz"
      "sha256-PPILO8Rw6Ddj/78jbgB2sSEbrBvGfeE9r0lGQPLecH4=";
  "h11" =
    spec "0.16.0"
      "https://files.pythonhosted.org/packages/01/ee/02a2c011bdab74c6fb3c75474d40b3052059d95df7e73351460c8588d963/h11-0.16.0.tar.gz"
      "sha256-TjW5Vs9FeS5MqliF5p+6AL28b/r7+gIDAOVJsgjuX/E=";
  "httpcore" =
    spec "1.0.9"
      "https://files.pythonhosted.org/packages/06/94/82699a10bca87a5556c9c59b5963f2d039dbd239f25bc2a63907a05a14cb/httpcore-1.0.9.tar.gz"
      "sha256-bjRGOvU/0qtdgH85mptF6jHD36InbxWiw/AK//bhdug=";
  "httpx" =
    spec "0.28.1"
      "https://files.pythonhosted.org/packages/b1/df/48c586a5fe32a0f01324ee087459e112ebb7224f646c0b5023f5e79e9956/httpx-0.28.1.tar.gz"
      "sha256-demMXxaw81tWeFb1l/Bv8icKN0RwpcI5IkJSjj4+Qvw=";
  "httpx-sse" =
    spec "0.4.3"
      "https://files.pythonhosted.org/packages/0f/4c/751061ffa58615a32c31b2d82e8482be8dd4a89154f003147acee90f2be9/httpx_sse-0.4.3.tar.gz"
      "sha256-mx7QEnRZpmAUrsPFa+vZPaPBvIu2YYyAggOaRIiadV0=";
  "idna" =
    spec "3.18"
      "https://files.pythonhosted.org/packages/cd/63/9496c57188a2ee585e0f1db071d75089a11e98aa86eb99d9d7618fc1edce/idna-3.18.tar.gz"
      "sha256-/7OFp+A5ZUzvGrnvMsb6/ig8DARnu6HZApc4zkoUqEg=";
  "jaraco-classes" =
    spec "3.4.0"
      "https://files.pythonhosted.org/packages/06/c0/ed4a27bc5571b99e3cff68f8a9fa5b56ff7df1c2251cc715a652ddd26402/jaraco.classes-3.4.0.tar.gz"
      "sha256-R6AktR0COcDdjIVAxsf0hL47j88LLYXBOCV4DTs/Os0=";
  "jaraco-context" =
    spec "6.1.2"
      "https://files.pythonhosted.org/packages/af/50/4763cd07e722bb6285316d390a164bc7e479db9d90daa769f22578f698b4/jaraco_context-6.1.2.tar.gz"
      "sha256-8abJ05HmYcxbjTmGH/B3p9wk3CODPM7lZLI0uByC3+M=";
  "jaraco-functools" =
    spec "4.5.0"
      "https://files.pythonhosted.org/packages/36/cf/ea4ef2920830dea3f5ab2ea4da6fb67724e6dca80ee2553788c3607243d0/jaraco_functools-4.5.0.tar.gz"
      "sha256-O7VmXqSgIM94pwQOiRVMd+2ts8p082ZHlmnFmZqnCwM=";
  "jiter" =
    spec "0.15.0"
      "https://files.pythonhosted.org/packages/60/28/edcfbbbf0cb15436f36664a8908a0df47ab9006298d4cd937dc08ea932d6/jiter-0.15.0-cp314-cp314-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
      "sha256-kMXbVSfCISSah2FgZjq4kazjWMF/e5yT7BR4t/BVDlw=";
  "jmespath" =
    spec "1.1.0"
      "https://files.pythonhosted.org/packages/d3/59/322338183ecda247fb5d1763a6cbe46eff7222eaeebafd9fa65d4bf5cb11/jmespath-1.1.0.tar.gz"
      "sha256-RyyH2A82AmroPG3dDx0F1OUQE07UYoUf1fdUyMPLuI0=";
  "json5" =
    spec "0.15.0"
      "https://files.pythonhosted.org/packages/e4/7d/05c46a96a78147ae3bf99c2f4169ce144a70220b8d6fcd56f6ec368b8ce9/json5-0.15.0.tar.gz"
      "sha256-dCTR8esdVtpuPXBkP1NhmGK0zoFEC9uOz9b4deW6SnE=";
  "jsonschema" =
    spec "4.26.0"
      "https://files.pythonhosted.org/packages/b3/fc/e067678238fa451312d4c62bf6e6cf5ec56375422aee02f9cb5f909b3047/jsonschema-4.26.0.tar.gz"
      "sha256-DCZwfi762Kob/Ft84XDz/MwuSRj/hZibqf+p+ssr4yY=";
  "jsonschema-specifications" =
    spec "2025.9.1"
      "https://files.pythonhosted.org/packages/19/74/a633ee74eb36c44aa6d1095e7cc5569bebf04342ee146178e2d36600708b/jsonschema_specifications-2025.9.1.tar.gz"
      "sha256-tUCYfyOedFYTx6kXbz7bcrgypKxGXPAnEiiDl4MrXo0=";
  "keyring" =
    spec "25.7.0"
      "https://files.pythonhosted.org/packages/43/4b/674af6ef2f97d56f0ab5153bf0bfa28ccb6c3ed4d1babf4305449668807b/keyring-25.7.0.tar.gz"
      "sha256-/gG9hes/j7PdBAXe/erJpbT28EOe27MUlXfyRKLoJFs=";
  "lark" =
    spec "1.3.1"
      "https://files.pythonhosted.org/packages/da/34/28fff3ab31ccff1fd4f6c7c7b0ceb2b6968d8ea4950663eadcb5720591a0/lark-1.3.1.tar.gz"
      "sha256-tCanptbVMYnTGPK2I2q11kKerwklnxyjPrcW7tENKQU=";
  "mako" =
    spec "1.4.2"
      "https://files.pythonhosted.org/packages/05/7f/0b891a82379ffd96d2d8cc6d435fb1055cdaed52829287f81d2a43fd71cb/mako-1.4.2.tar.gz"
      "sha256-ciegYO469VpJOvYdc9a+7xMES4HbqVhnNsE5RfCUZM4=";
  "markdown-it-py" =
    spec "4.2.0"
      "https://files.pythonhosted.org/packages/06/ff/7841249c247aa650a76b9ee4bbaeae59370dc8bfd2f6c01f3630c35eb134/markdown_it_py-4.2.0.tar.gz"
      "sha256-BKIWgdb7tiPeU/bzZNNSMJ1AlN1BlAQKEP1Rgz5BjUk=";
  "markupsafe" =
    spec "3.0.3"
      "https://files.pythonhosted.org/packages/41/3c/a36c2450754618e62008bf7435ccb0f88053e07592e6028a34776213d877/markupsafe-3.0.3-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-RXppqVdwZMBal8QfTmUUhlLbB4o6UJA55k00Z7nn75c=";
  "mcp" =
    spec "1.30.0"
      "https://files.pythonhosted.org/packages/ba/93/0142dc84a666daf8ad51a34268f34c12fd6fda4f3810c4be2504eecc8212/mcp-1.30.0.tar.gz"
      "sha256-RFQUYl/OXClfqlBbsRus7OZhq29AKNV8k121eCC3o+Q=";
  "mdurl" =
    spec "0.1.2"
      "https://files.pythonhosted.org/packages/d6/54/cfe61301667036ec958cb99bd3efefba235e65cdeb9c84d24a8293ba1d90/mdurl-0.1.2.tar.gz"
      "sha256-u0E9KfXuo48x3UdU3XN31EZRFvsgdYX5e/klWIaHwbo=";
  "more-itertools" =
    spec "11.1.0"
      "https://files.pythonhosted.org/packages/de/1d/f4da6f02cdffe04d6362210b807146a26044c88d839208aec273bb0d9184/more_itertools-11.1.0.tar.gz"
      "sha256-SOj02eflh4Vx7PbytOV2NPk81HTMjPvSN28tEbOW4w0=";
  "openai" =
    spec "2.41.0"
      "https://files.pythonhosted.org/packages/3c/a6/5815fe2e2aca74b36c650d1bd43b69827cee568073d0d2d9b6fc5aaac80c/openai-2.41.0.tar.gz"
      "sha256-21w2Ks1mBLhPB2q776ZoJupLRuy6KVTthm5qFJoTUsA=";
  "openai-agents" =
    spec "0.13.6"
      "https://files.pythonhosted.org/packages/4f/e8/a3bc1a91af9c71d2934f8e2f3eee2954540fa95d47b0e3f155d348d91b38/openai_agents-0.13.6.tar.gz"
      "sha256-3ns63XkzrnBKXublMfZQ2Kq7PrqhYx9Fi6OWhKXtlm4=";
  "opentelemetry-api" =
    spec "1.44.0"
      "https://files.pythonhosted.org/packages/ee/8b/aa9e2d8b8dfa7c946f7dec5d1f8f6ba8eca062f43509a06bdb5ce93d26c0/opentelemetry_api-1.44.0.tar.gz"
      "sha256-Z2R+XpVm7c9CEWb98CKzU3+BhjXaqFKyieNGBNxvszo=";
  "packaging" =
    spec "26.3"
      "https://files.pythonhosted.org/packages/7d/fa/3944b40b07da9ce895c0e6303a5ab7d53da063554f534556b134a54d6093/packaging-26.3.tar.gz"
      "sha256-lO3CVkJK84di6zEwbu0ovrnw78UKiDdJLJ1v1gBK7Xk=";
  "pendulum" =
    spec "3.2.0"
      "https://files.pythonhosted.org/packages/57/b6/333a0fcb33bf15eb879a46a11ce6300c1698a141e689665fe430783ff8d6/pendulum-3.2.0-cp314-cp314-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
      "sha256-p9Lpv7Blcn2Gdueto3k7R6JDSVAKXpY3QENV5ILIIr4=";
  "pexpect" =
    spec "4.9.0"
      "https://files.pythonhosted.org/packages/42/92/cc564bf6381ff43ce1f4d06852fc19a2f11d180f23dc32d9588bee2f149d/pexpect-4.9.0.tar.gz"
      "sha256-7n1BEj88mREFDqLC2sEHVo3EOy07DHVXozISw5jq0w8=";
  "pillow" =
    spec "12.3.0"
      "https://files.pythonhosted.org/packages/5c/44/c85361f65dbe00eea8576ee467c768d25129989efb76e94f205e9ca9bb46/pillow-12.3.0-cp314-cp314-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-JRv5W2cBfiexPYL1syYjTKYtcPnPTCuQMt4jWKOxLHs=";
  "prompt-toolkit" =
    spec "3.0.52"
      "https://files.pythonhosted.org/packages/a1/96/06e01a7b38dce6fe1db213e061a4602dd6032a8a97ef6c1a862537732421/prompt_toolkit-3.0.52.tar.gz"
      "sha256-KM3hkpKcjnMh3oXeHdvnNvE3UUiwLy4X7dhABCsb6FU=";
  "protobuf" =
    spec "6.33.6"
      "https://files.pythonhosted.org/packages/66/70/e908e9c5e52ef7c3a6c7902c9dfbb34c7e29c25d2f81ade3856445fd5c94/protobuf-6.33.6.tar.gz"
      "sha256-pnaNJSSDEsKXVYr5ap+ckp6MTO4GWcsH54BzEJXzgTU=";
  "psutil" =
    spec "7.2.2"
      "https://files.pythonhosted.org/packages/aa/c6/d1ddf4abb55e93cebc4f2ed8b5d6dbad109ecb8d63748dd2b20ab5e57ebe/psutil-7.2.2.tar.gz"
      "sha256-B0b1+NQGrzRP1UfxyNql9cM9vCk7uNahbYC0u4j1k3I=";
  "pydantic" =
    spec "2.13.4"
      "https://files.pythonhosted.org/packages/18/a5/b60d21ac674192f8ab0ba4e9fd860690f9b4a6e51ca5df118733b487d8d6/pydantic-2.13.4.tar.gz"
      "sha256-xAdWtXraqLHv7s7VwZbz87fENfkOhOp/RDkBvsgJnvY=";
  "pydantic-core" =
    spec "2.46.4"
      "https://files.pythonhosted.org/packages/89/1d/8eff589b45bb8190a9d12c49cfad0f176a5cbd1534908a6b5125e2886239/pydantic_core-2.46.4-cp314-cp314-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
      "sha256-el+TBHJlCoJikWMCPmMNFghj/OUkxhb05RhuXenZpJs=";
  "pydantic-settings" =
    spec "2.15.0"
      "https://files.pythonhosted.org/packages/68/ca/31c57507b13119d7d3cfa1576dad2911a4861e3be07b579395f4e9d393f9/pydantic_settings-2.15.0.tar.gz"
      "sha256-aUt5PoT3Zrp2qQ6978AdCpoEXasDgr7nA5Pak3Eq0Rc=";
  "pygments" =
    spec "2.20.0"
      "https://files.pythonhosted.org/packages/c3/b2/bc9c9196916376152d655522fdcebac55e66de6603a76a02bca1b6414f6c/pygments-2.20.0.tar.gz"
      "sha256-Z1fNA3aAU/+Z8wOcGjbWwKoLJjQ4/KsXUgswowOoK18=";
  "pyjwt" =
    spec "2.15.0"
      "https://files.pythonhosted.org/packages/02/a5/5197bfd06417837ac079921c66fa6393f1dea3557272a263cebfef69e432/pyjwt-2.15.0.tar.gz"
      "sha256-sRxfl5HXv1HCs5qB7Wafay271mnfKUL2xgFn6ePRq+Q=";
  "pyte" =
    spec "0.8.2"
      "https://files.pythonhosted.org/packages/ab/ab/b599762933eba04de7dc5b31ae083112a6c9a9db15b01d3109ad797559d9/pyte-0.8.2.tar.gz"
      "sha256-Wvlw6EP6lqlxSdZOFwyYRyHyDlIiei9X8KVCB/CPCD8=";
  "python-dateutil" =
    spec "2.9.0.post0"
      "https://files.pythonhosted.org/packages/66/c0/0c8b6ad9f17a802ee498c46e004a0eb49bc148f2fd230864601a86dcf6db/python-dateutil-2.9.0.post0.tar.gz"
      "sha256-N91UII2n4c2HU4ghfV4A69QXkkn5D7ckN+kaNUWaCtM=";
  "python-dotenv" =
    spec "1.2.2"
      "https://files.pythonhosted.org/packages/82/ed/0301aeeac3e5353ef3d94b6ec08bbcabd04a72018415dcb29e588514bba8/python_dotenv-1.2.2.tar.gz"
      "sha256-LDcakfvXuggsLB3B+L+JyiJWSgh8LCh82bZird55nPM=";
  "python-multipart" =
    spec "0.0.32"
      "https://files.pythonhosted.org/packages/5b/42/55c32bb9b12693c092ad250a0e82edb5b31ddeda6eb772de5f308b3804ad/python_multipart-0.0.32.tar.gz"
      "sha256-vlS38/oWe7g+T82Ta4h7cI9OV/51kRwCrr9T76+Nk44=";
  "pyyaml" =
    spec "6.0.3"
      "https://files.pythonhosted.org/packages/88/f9/16491d7ed2a919954993e48aa941b200f38040928474c9e85ea9e64222c3/pyyaml-6.0.3-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-xFi20IT5uTUGG8NiFuimmn4pOi8eaL+Vbc2ebLzRQ/U=";
  "referencing" =
    spec "0.37.0"
      "https://files.pythonhosted.org/packages/22/f5/df4e9027acead3ecc63e50fe1e36aca1523e1719559c499951bb4b53188f/referencing-0.37.0.tar.gz"
      "sha256-RK78MULFuEJTgWOss3PiTM5mMr1UvbAbIa1YY0ifUNg=";
  "regex" =
    spec "2026.5.9"
      "https://files.pythonhosted.org/packages/d9/27/2af43dd1dc201d1fecefda64a45f4ad0995855b92724f795a777b402ee69/regex-2026.5.9-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-DeXPGTmXOE7Sym8c1PeAVbJV2T2C1ajNa6DRHBCxZ+Q=";
  "requests" =
    spec "2.34.2"
      "https://files.pythonhosted.org/packages/ac/c3/e2a2b89f2d3e2179abd6d00ebd70bff6273f37fb3e0cc209f48b39d00cbf/requests-2.34.2.tar.gz"
      "sha256-8oiSTK5OKUY2mNbWC8ak2mnIkYWtHgvMQQT1hOlgue0=";
  "rich" =
    spec "15.0.0"
      "https://files.pythonhosted.org/packages/c0/8f/0722ca900cc807c13a6a0c696dacf35430f72e0ec571c4275d2371fca3e9/rich-15.0.0.tar.gz"
      "sha256-7dB6SCTGtAGJ+3rJvExSU26XgPu/vd9vHiUCwxsGjDY=";
  "rpds-py" =
    spec "2026.5.1"
      "https://files.pythonhosted.org/packages/19/c8/d63bb75b68afe77b229e3021c6031bcaf01da5db5b0e69d0d10f9ba679a7/rpds_py-2026.5.1-cp314-cp314-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
      "sha256-IYRqrA7S4FifOMEtxE53u2TklLdx6tvPFpy6AFZrp7o=";
  "six" =
    spec "1.17.0"
      "https://files.pythonhosted.org/packages/94/e7/b2c673351809dca68a0e064b6af791aa332cf192da575fd474ed7d6f16a2/six-1.17.0.tar.gz"
      "sha256-/3AzXUaOfrbsZblbmdOig2VGBj9jrMUXHeNn6DSTKoE=";
  "sniffio" =
    spec "1.3.1"
      "https://files.pythonhosted.org/packages/a2/87/a6771e1546d97e7e041b6ae58d80074f81b7d5121207425c964ddf5cfdbd/sniffio-1.3.1.tar.gz"
      "sha256-9DJO3GcKD0l1CoG4lfNcOtuEPMpG8FMPefwbq7I3idw=";
  "sqlalchemy" =
    spec "2.0.50"
      "https://files.pythonhosted.org/packages/31/26/ef168b184a25701f9995e8fb7e503fafd7a99c1c77cda1bc1a26ea2ed486/sqlalchemy-2.0.50-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-bCBq7FGaLnvQirv7M0NuMl/SLGMtnCGpBH43bOJBZG4=";
  "sse-starlette" =
    spec "3.4.4"
      "https://files.pythonhosted.org/packages/f7/2b/58abc2d1fd397e7dde08e947e05c884d8ef2f78d5e2588c17a12d42d6994/sse_starlette-3.4.4.tar.gz"
      "sha256-B+D6BGATi68lzdX7KGg0csOZXcFkIiUZGzgy1iUmvLA=";
  "starlette" =
    spec "1.3.1"
      "https://files.pythonhosted.org/packages/eb/e3/7c1dc7381d9f8ab7d854328ebfa884e62cb3f3d8549ddfd37c7814f42afa/starlette-1.3.1.tar.gz"
      "sha256-BdAhMZPy+6rmDi7LWTtK3UJirU5GU2tUq+NvEacXJOA=";
  "tiktoken" =
    spec "0.14.0"
      "https://files.pythonhosted.org/packages/5b/7d/144af98dc5ad68108451a82e2f5a17f80e2663f5115058b8dfd215c1ad02/tiktoken-0.14.0-cp314-cp314-manylinux_2_28_x86_64.whl"
      "sha256-40Qruy8MWIzsh2Bh43rme0VbnfmXiwA8j+MORfLvW0I=";
  "tomlkit" =
    spec "0.15.0"
      "https://files.pythonhosted.org/packages/51/db/03eaf4331631ef6b27d6e3c9b68c54dc6f0d63d87201fed600cc409307fd/tomlkit-0.15.0.tar.gz"
      "sha256-fRqey6MIZjghGxOBTqeckN1U3RGZNWQ3bzqpInH1x6M=";
  "tqdm" =
    spec "4.68.1"
      "https://files.pythonhosted.org/packages/06/b3/36c8ecf72e8925200671613332db156d84b99b3aee742a41c1938ebb0808/tqdm-4.68.1.tar.gz"
      "sha256-/BY9lrKHvQMeGqJEIc5EEbJVWb0KG+T+ZJvapNLAK/U=";
  "types-requests" =
    spec "2.33.0.20260518"
      "https://files.pythonhosted.org/packages/e0/01/c5a19253fe1ac159159ddf9a3a07cec8bb5e486ec4d9002ad2821da0e5d2/types_requests-2.33.0.20260518.tar.gz"
      "sha256-33vTv+DKhALfuEHn2b5xS7VXggMoPWbX3E72k0NEml4=";
  "typing-extensions" =
    spec "4.15.0"
      "https://files.pythonhosted.org/packages/72/94/1a15dd82efb362ac84269196e94cf00f187f7ed21c242792a923cdb1c61f/typing_extensions-4.15.0.tar.gz"
      "sha256-DOpI0XPMEvoo7KvDuDfqPPbzjG0RNvhcuq9ZiYSGFGY=";
  "typing-inspection" =
    spec "0.4.2"
      "https://files.pythonhosted.org/packages/55/e3/70399cb7dd41c10ac53367ae42139cf4b1ca5f36bb3dc6c9d33acdb43655/typing_inspection-0.4.2.tar.gz"
      "sha256-ulYcSKZ8WVgAcIPThsMpVGSSiwH6pzWrhUfFaS6H9GQ=";
  "tzdata" =
    spec "2026.2"
      "https://files.pythonhosted.org/packages/ba/19/1b9b0e29f30c6d35cb345486df41110984ea67ae69dddbc0e8a100999493/tzdata-2026.2.tar.gz"
      "sha256-kXP959gNkBjgKmYuFo5aLQT4fEHqF0sTn772Qu2mLRA=";
  "urllib3" =
    spec "2.8.0"
      "https://files.pythonhosted.org/packages/e3/05/b17359e1cefb4f909b5e40b1b90a496d987258916dbbf88e842c729f510e/urllib3-2.8.0.tar.gz"
      "sha256-Y78urUyHlCbr8i7yp4HutKo7SueYoENVBvhof9W7m2M=";
  "uvicorn" =
    spec "0.49.0"
      "https://files.pythonhosted.org/packages/c4/1f/fa18009dea8469069cca78a4e877a008ab78f08b064bfc9ab891579077ff/uvicorn-0.49.0.tar.gz"
      "sha256-6/QnGqWA2d6X+TGS1FlRdt9ukfmq6RnKc+T8B98eZqM=";
  "wcwidth" =
    spec "0.8.1"
      "https://files.pythonhosted.org/packages/49/b4/51fe890511f0f242d07cb1ebe6a5b6db417262b9d2568b460347c57d95cc/wcwidth-0.8.1.tar.gz"
      "sha256-+vW0pTZqctxJytSM3yH1K99jvdqZUXjkg7okf/eQibk=";
  "websockets" =
    spec "14.2"
      "https://files.pythonhosted.org/packages/94/54/8359678c726243d19fae38ca14a334e740782336c9f19700858c4eb64a1e/websockets-14.2.tar.gz"
      "sha256-UFntnFSUXvsyHwlwhLTH5SwkbyyGmBWHamnR78StbrU=";
  "zstandard" =
    spec "0.25.0"
      "https://files.pythonhosted.org/packages/31/dc/cc50210e11e465c975462439a492516a73300ab8caa8f5e0902544fd748b/zstandard-0.25.0-cp314-cp314-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
      "sha256-4Ju2JStkdtjVYQDoFHuAO++poSzqFEu+Yp3VCIANGtA=";
}
