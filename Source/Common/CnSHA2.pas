{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2017 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnSHA2;
{* |<PRE>
================================================================================
* 软件名称：开发包基础库
* 单元名称：SHA2(SHA224/256)算法单元
* 单元作者：刘啸（Liu Xiao）
* 备    注：D567下可以用有符号 Int64 代替无符号 UInt64 来计算 SHA512/384，原因是
*           基于补码规则，有无符号数的加减移位以及溢出的舍弃机制等都相同，唯一不
*           同的是比较，而本单元中没有类似的比较。
* 开发平台：PWinXP + Delphi 5.0
* 兼容测试：PWinXP/7 + Delphi 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id: CnSHA2.pas 426 2016-09-27 07:01:49Z liuxiao $
* 修改记录：2016.09.30 V1.1
*               实现 SHA512/384。D567下用有符号 Int64 代替无符号 UInt64
*           2016.09.27 V1.0
*               创建单元。从网上佚名 C 代码与 Pascal 代码混合移植而来
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}

uses
  SysUtils, Windows, Classes;

type
  TSHAGeneralDigest = array[0..63] of Byte;

  TSHA224Digest = array[0..27] of Byte;

  TSHA256Digest = array[0..31] of Byte;

  TSHA384Digest = array[0..47] of Byte;

  TSHA512Digest = array[0..63] of Byte;

  TSHA256Context = record
    DataLen: DWORD;
    Data: array[0..63] of Byte;
    BitLen: Int64;
    State: array[0..7] of DWORD;
    Ipad: array[0..63] of Byte;      {!< HMAC: inner padding        }
    Opad: array[0..63] of Byte;      {!< HMAC: outer padding        }
  end;

  TSHA224Context = TSHA256Context;

  TSHA512Context = record
    DataLen: DWORD;
    Data: array[0..127] of Byte;
    BitLen: Int64;
    State: array[0..7] of Int64;
    Ipad: array[0..127] of Byte;      {!< HMAC: inner padding        }
    Opad: array[0..127] of Byte;      {!< HMAC: outer padding        }
  end;

  TSHA384Context = TSHA512Context;

  TSHACalcProgressFunc = procedure(ATotal, AProgress: Int64; var Cancel:
    Boolean) of object;
  {* 进度回调事件类型声明}

function SHA224Buffer(const Buffer; Count: LongWord): TSHA224Digest;
{* 对数据块进行SHA224转换
 |<PRE>
   const Buffer     - 要计算的数据块
   Count: LongWord  - 数据块长度
 |</PRE>}

function SHA256Buffer(const Buffer; Count: LongWord): TSHA256Digest;
{* 对数据块进行SHA256转换
 |<PRE>
   const Buffer     - 要计算的数据块
   Count: LongWord  - 数据块长度
 |</PRE>}

function SHA384Buffer(const Buffer; Count: LongWord): TSHA384Digest;
{* 对数据块进行SHA384转换
 |<PRE>
   const Buffer     - 要计算的数据块
   Count: LongWord  - 数据块长度
 |</PRE>}

function SHA512Buffer(const Buffer; Count: LongWord): TSHA512Digest;
{* 对数据块进行SHA512转换
 |<PRE>
  const Buffer     - 要计算的数据块
  Count: LongWord  - 数据块长度
 |</PRE>}

function SHA224String(const Str: string): TSHA224Digest;
{* 对String类型数据进行SHA224转换，注意D2009或以上版本的string为UnicodeString，
   因此对同一个字符串的计算结果，和D2007或以下版本的会不同，使用时请注意
 |<PRE>
   Str: string       - 要计算的字符串
 |</PRE>}

function SHA256String(const Str: string): TSHA256Digest;
{* 对String类型数据进行SHA256转换，注意D2009或以上版本的string为UnicodeString，
   因此对同一个字符串的计算结果，和D2007或以下版本的会不同，使用时请注意
 |<PRE>
   Str: string       - 要计算的字符串
 |</PRE>}

function SHA384String(const Str: string): TSHA384Digest;
{* 对String类型数据进行SHA384转换，注意D2009或以上版本的string为UnicodeString，
   因此对同一个字符串的计算结果，和D2007或以下版本的会不同，使用时请注意
 |<PRE>
   Str: string       - 要计算的字符串
 |</PRE>}

function SHA512String(const Str: string): TSHA512Digest;
{* 对String类型数据进行SHA512转换，注意D2009或以上版本的string为UnicodeString，
   因此对同一个字符串的计算结果，和D2007或以下版本的会不同，使用时请注意
 |<PRE>
   Str: string       - 要计算的字符串
 |</PRE>}

function SHA224StringA(const Str: AnsiString): TSHA224Digest;
{* 对AnsiString类型数据进行SHA224转换
 |<PRE>
   Str: AnsiString       - 要计算的字符串
 |</PRE>}

function SHA224StringW(const Str: WideString): TSHA224Digest;
{* 对 WideString类型数据进行SHA224转换
 |<PRE>
   Str: WideString       - 要计算的字符串
 |</PRE>}

function SHA256StringA(const Str: AnsiString): TSHA256Digest;
{* 对AnsiString类型数据进行SHA256转换
 |<PRE>
   Str: AnsiString       - 要计算的字符串
 |</PRE>}

function SHA256StringW(const Str: WideString): TSHA256Digest;
{* 对 WideString类型数据进行SHA256转换
 |<PRE>
   Str: WideString       - 要计算的字符串
 |</PRE>}

function SHA384StringA(const Str: AnsiString): TSHA384Digest;
{* 对AnsiString类型数据进行SHA384转换
 |<PRE>
   Str: AnsiString       - 要计算的字符串
 |</PRE>}

function SHA384StringW(const Str: WideString): TSHA384Digest;
{* 对 WideString类型数据进行SHA384转换
 |<PRE>
   Str: WideString       - 要计算的字符串
 |</PRE>}

function SHA512StringA(const Str: AnsiString): TSHA512Digest;
{* 对AnsiString类型数据进行SHA512转换
|<PRE>
 Str: AnsiString       - 要计算的字符串
|</PRE>}

function SHA512StringW(const Str: WideString): TSHA512Digest;
{* 对 WideString类型数据进行SHA512转换
|<PRE>
 Str: WideString       - 要计算的字符串
|</PRE>}

function SHA224File(const FileName: string; CallBack: TSHACalcProgressFunc =
  nil): TSHA224Digest;
{* 对指定文件数据进行SHA256转换
 |<PRE>
   FileName: string  - 要计算的文件名
   CallBack: TSHACalcProgressFunc - 进度回调函数，默认为空
 |</PRE>}

function SHA224Stream(Stream: TStream; CallBack: TSHACalcProgressFunc = nil):
  TSHA224Digest;
{* 对指定流数据进行SHA224转换
 |<PRE>
   Stream: TStream  - 要计算的流内容
   CallBack: TSHACalcProgressFunc - 进度回调函数，默认为空
 |</PRE>}

function SHA256File(const FileName: string; CallBack: TSHACalcProgressFunc =
  nil): TSHA256Digest;
{* 对指定文件数据进行SHA256转换
 |<PRE>
   FileName: string  - 要计算的文件名
   CallBack: TSHACalcProgressFunc - 进度回调函数，默认为空
 |</PRE>}

function SHA256Stream(Stream: TStream; CallBack: TSHACalcProgressFunc = nil):
  TSHA256Digest;
{* 对指定流数据进行SHA256转换
 |<PRE>
   Stream: TStream  - 要计算的流内容
   CallBack: TSHACalcProgressFunc - 进度回调函数，默认为空
 |</PRE>}

function SHA384File(const FileName: string; CallBack: TSHACalcProgressFunc =
  nil): TSHA384Digest;
{* 对指定文件数据进行SHA384转换
 |<PRE>
   FileName: string  - 要计算的文件名
   CallBack: TSHACalcProgressFunc - 进度回调函数，默认为空
 |</PRE>}

function SHA384Stream(Stream: TStream; CallBack: TSHACalcProgressFunc = nil):
  TSHA384Digest;
{* 对指定流数据进行SHA384转换
 |<PRE>
   Stream: TStream  - 要计算的流内容
   CallBack: TSHACalcProgressFunc - 进度回调函数，默认为空
 |</PRE>}

function SHA512File(const FileName: string; CallBack: TSHACalcProgressFunc =
  nil): TSHA512Digest;
{* 对指定文件数据进行SHA512转换
 |<PRE>
   FileName: string  - 要计算的文件名
   CallBack: TSHACalcProgressFunc - 进度回调函数，默认为空
 |</PRE>}

function SHA512Stream(Stream: TStream; CallBack: TSHACalcProgressFunc = nil):
  TSHA512Digest;
{* 对指定流数据进行SHA512转换
 |<PRE>
   Stream: TStream  - 要计算的流内容
   CallBack: TSHACalcProgressFunc - 进度回调函数，默认为空
 |</PRE>}

procedure SHA224Init(var Context: TSHA224Context);

procedure SHA224Update(var Context: TSHA224Context; Buffer: PAnsiChar; Len: Cardinal);

procedure SHA224Final(var Context: TSHA224Context; var Digest: TSHA224Digest);

procedure SHA256Init(var Context: TSHA256Context);

procedure SHA256Update(var Context: TSHA256Context; Buffer: PAnsiChar; Len: Cardinal);

procedure SHA256Final(var Context: TSHA256Context; var Digest: TSHA256Digest);

procedure SHA384Init(var Context: TSHA384Context);

procedure SHA384Update(var Context: TSHA384Context; Buffer: PAnsiChar; Len: Cardinal);

procedure SHA384Final(var Context: TSHA384Context; var Digest: TSHA384Digest);

procedure SHA512Init(var Context: TSHA512Context);

procedure SHA512Update(var Context: TSHA512Context; Buffer: PAnsiChar; Len: Cardinal);

procedure SHA512Final(var Context: TSHA512Context; var Digest: TSHA512Digest);

function SHA224Print(const Digest: TSHA224Digest): string;
{* 以十六进制格式输出SHA224计算值
 |<PRE>
   Digest: TSHA224Digest  - 指定的SHA224计算值
 |</PRE>}

function SHA256Print(const Digest: TSHA256Digest): string;
{* 以十六进制格式输出SHA256计算值
 |<PRE>
   Digest: TSHA256Digest  - 指定的SHA256计算值
 |</PRE>}

function SHA384Print(const Digest: TSHA384Digest): string;
{* 以十六进制格式输出SHA384计算值
 |<PRE>
   Digest: TSHA384Digest  - 指定的SHA384计算值
 |</PRE>}

function SHA512Print(const Digest: TSHA512Digest): string;
{* 以十六进制格式输出SHA512计算值
 |<PRE>
   Digest: TSHA512Digest  - 指定的SHA512计算值
 |</PRE>}

function SHA224Match(const D1, D2: TSHA224Digest): Boolean;
{* 比较两个SHA224计算值是否相等
 |<PRE>
   D1: TSHA224Digest   - 需要比较的SHA224计算值
   D2: TSHA224Digest   - 需要比较的SHA224计算值
 |</PRE>}

function SHA256Match(const D1, D2: TSHA256Digest): Boolean;
{* 比较两个SHA256计算值是否相等
 |<PRE>
   D1: TSHA256Digest   - 需要比较的SHA256计算值
   D2: TSHA256Digest   - 需要比较的SHA256计算值
 |</PRE>}

function SHA384Match(const D1, D2: TSHA384Digest): Boolean;
{* 比较两个SHA384计算值是否相等
 |<PRE>
   D1: TSHA384Digest   - 需要比较的SHA384计算值
   D2: TSHA384Digest   - 需要比较的SHA384计算值
 |</PRE>}

function SHA512Match(const D1, D2: TSHA512Digest): Boolean;
{* 比较两个SHA512计算值是否相等
 |<PRE>
   D1: TSHA512Digest   - 需要比较的SHA512计算值
   D2: TSHA512Digest   - 需要比较的SHA512计算值
 |</PRE>}

function SHA224DigestToStr(aDig: TSHA224Digest): string;
{* SHA224计算值转 string
 |<PRE>
   aDig: TSHA224Digest   - 需要转换的SHA224计算值
 |</PRE>}

function SHA256DigestToStr(aDig: TSHA256Digest): string;
{* SHA256计算值转 string
 |<PRE>
   aDig: TSHA256Digest   - 需要转换的SHA256计算值
 |</PRE>}

function SHA384DigestToStr(aDig: TSHA384Digest): string;
{* SHA384计算值转 string
 |<PRE>
   aDig: TSHA384Digest   - 需要转换的SHA384计算值
 |</PRE>}

function SHA512DigestToStr(aDig: TSHA512Digest): string;
{* SHA512计算值转 string
 |<PRE>
   aDig: TSHA512Digest   - 需要转换的SHA512计算值
 |</PRE>}

procedure SHA224HmacInit(var Context: TSHA224Context; Key: PAnsiChar; KeyLength: Integer);

procedure SHA224HmacUpdate(var Context: TSHA224Context; Input: PAnsiChar; Length:
  LongWord);

procedure SHA224HmacFinal(var Context: TSHA224Context; var Output: TSHA224Digest);

procedure SHA224Hmac(Key: PAnsiChar; KeyLength: Integer; Input: PAnsiChar;
  Length: LongWord; var Output: TSHA224Digest);

procedure SHA256HmacInit(var Context: TSHA256Context; Key: PAnsiChar; KeyLength: Integer);

procedure SHA256HmacUpdate(var Context: TSHA256Context; Input: PAnsiChar; Length:
  LongWord);

procedure SHA256HmacFinal(var Context: TSHA256Context; var Output: TSHA256Digest);

procedure SHA256Hmac(Key: PAnsiChar; KeyLength: Integer; Input: PAnsiChar;
  Length: LongWord; var Output: TSHA256Digest);

procedure SHA384HmacInit(var Context: TSHA384Context; Key: PAnsiChar; KeyLength: Integer);

procedure SHA384HmacUpdate(var Context: TSHA384Context; Input: PAnsiChar; Length:
  LongWord);

procedure SHA384HmacFinal(var Context: TSHA384Context; var Output: TSHA384Digest);

procedure SHA384Hmac(Key: PAnsiChar; KeyLength: Integer; Input: PAnsiChar;
  Length: LongWord; var Output: TSHA384Digest);

procedure SHA512HmacInit(var Context: TSHA512Context; Key: PAnsiChar; KeyLength: Integer);

procedure SHA512HmacUpdate(var Context: TSHA512Context; Input: PAnsiChar; Length:
  LongWord);

procedure SHA512HmacFinal(var Context: TSHA512Context; var Output: TSHA512Digest);

procedure SHA512Hmac(Key: PAnsiChar; KeyLength: Integer; Input: PAnsiChar;
  Length: LongWord; var Output: TSHA512Digest);

{* Hash-based Message Authentication Code (based on SHA256) }

implementation

type
  TSHAType = (stSHA224, stSHA256, stSHA384, stSHA512);

{$IFDEF SUPPORT_UINT64}
  TUInt64 = UInt64;
{$ELSE}
  // D 5,6,7 下暂且用有符号的 Int64 来代替无符号的 Int64
  TUInt64 = Int64;
{$ENDIF}

const
  MAX_FILE_SIZE = 512 * 1024 * 1024;
  // If file size <= this size (bytes), using Mapping, else stream

  KEYS256: array[0..63] of DWORD = ($428A2F98, $71374491, $B5C0FBCF, $E9B5DBA5,
    $3956C25B, $59F111F1, $923F82A4, $AB1C5ED5, $D807AA98, $12835B01, $243185BE,
    $550C7DC3, $72BE5D74, $80DEB1FE, $9BDC06A7, $C19BF174, $E49B69C1, $EFBE4786,
    $0FC19DC6, $240CA1CC, $2DE92C6F, $4A7484AA, $5CB0A9DC, $76F988DA, $983E5152,
    $A831C66D, $B00327C8, $BF597FC7, $C6E00BF3, $D5A79147, $06CA6351, $14292967,
    $27B70A85, $2E1B2138, $4D2C6DFC, $53380D13, $650A7354, $766A0ABB, $81C2C92E,
    $92722C85, $A2BFE8A1, $A81A664B, $C24B8B70, $C76C51A3, $D192E819, $D6990624,
    $F40E3585, $106AA070, $19A4C116, $1E376C08, $2748774C, $34B0BCB5, $391C0CB3,
    $4ED8AA4A, $5B9CCA4F, $682E6FF3, $748F82EE, $78A5636F, $84C87814, $8CC70208,
    $90BEFFFA, $A4506CEB, $BEF9A3F7, $C67178F2);

  KEYS512: array[0..79] of TUInt64 = ($428A2F98D728AE22, $7137449123EF65CD,
    $B5C0FBCFEC4D3B2F, $E9B5DBA58189DBBC, $3956C25BF348B538, $59F111F1B605D019,
    $923F82A4AF194F9B, $AB1C5ED5DA6D8118, $D807AA98A3030242, $12835B0145706FBE,
    $243185BE4EE4B28C, $550C7DC3D5FFB4E2, $72BE5D74F27B896F, $80DEB1FE3B1696B1,
    $9BDC06A725C71235, $C19BF174CF692694, $E49B69C19EF14AD2, $EFBE4786384F25E3,
    $0FC19DC68B8CD5B5, $240CA1CC77AC9C65, $2DE92C6F592B0275, $4A7484AA6EA6E483,
    $5CB0A9DCBD41FBD4, $76F988DA831153B5, $983E5152EE66DFAB, $A831C66D2DB43210,
    $B00327C898FB213F, $BF597FC7BEEF0EE4, $C6E00BF33DA88FC2, $D5A79147930AA725,
    $06CA6351E003826F, $142929670A0E6E70, $27B70A8546D22FFC, $2E1B21385C26C926,
    $4D2C6DFC5AC42AED, $53380D139D95B3DF, $650A73548BAF63DE, $766A0ABB3C77B2A8,
    $81C2C92E47EDAEE6, $92722C851482353B, $A2BFE8A14CF10364, $A81A664BBC423001,
    $C24B8B70D0F89791, $C76C51A30654BE30, $D192E819D6EF5218, $D69906245565A910,
    $F40E35855771202A, $106AA07032BBD1B8, $19A4C116B8D2D0C8, $1E376C085141AB53,
    $2748774CDF8EEB99, $34B0BCB5E19B48A8, $391C0CB3C5C95A63, $4ED8AA4AE3418ACB,
    $5B9CCA4F7763E373, $682E6FF3D6B2B8A3, $748F82EE5DEFB2FC, $78A5636F43172F60,
    $84C87814A1F0AB72, $8CC702081A6439EC, $90BEFFFA23631E28, $A4506CEBDE82BDE9,
    $BEF9A3F7B2C67915, $C67178F2E372532B, $CA273ECEEA26619C, $D186B8C721C0C207,
    $EADA7DD6CDE0EB1E, $F57D4F7FEE6ED178, $06F067AA72176FBA, $0A637DC5A2C898A6,
    $113F9804BEF90DAE, $1B710B35131C471B, $28DB77F523047D84, $32CAAB7B40C72493,
    $3C9EBE0A15C9BEBC, $431D67C49C100D4C, $4CC5D4BECB3E42B6, $597F299CFC657E2A,
    $5FCB6FAB3AD6FAEC, $6C44198C4A475817);
{$R-}

function ROTLeft256(A, B: DWORD): DWORD;
begin
  Result := (A shl B) or (A shr (32 - B));
end;

function ROTRight256(A, B: DWORD): DWORD;
begin
  Result := (A shr B) or (A shl (32 - B));
end;

function ROTRight512(X: TUInt64; Y: Integer): TUInt64;
begin
  Result := (X shr Y) or (X shl (64 - Y));
end;

function SHR512(X: TUInt64; Y: Integer): TUInt64;
begin
  Result := (X and $FFFFFFFFFFFFFFFF) shr Y;
end;

function CH256(X, Y, Z: DWORD): DWORD;
begin
  Result := (X and Y) xor ((not X) and Z);
end;

function CH512(X, Y, Z: TUInt64): TUInt64;
begin
  Result := (((Y xor Z) and X) xor Z);
end;

function MAJ256(X, Y, Z: DWORD): DWORD;
begin
  Result := (X and Y) xor (X and Z) xor (Y and Z);
end;

function MAJ512(X, Y, Z: TUInt64): TUInt64;
begin
  Result := ((X or Y) and Z) or (X and Y);
end;

function EP0256(X: DWORD): DWORD;
begin
  Result := ROTRight256(X, 2) xor ROTRight256(X, 13) xor ROTRight256(X, 22);
end;

function EP1256(X: DWORD): DWORD;
begin
  Result := ROTRight256(X, 6) xor ROTRight256(X, 11) xor ROTRight256(X, 25);
end;

function SIG0256(X: DWORD): DWORD;
begin
  Result := ROTRight256(X, 7) xor ROTRight256(X, 18) xor (X shr 3);
end;

function SIG1256(X: DWORD): DWORD;
begin
  Result := ROTRight256(X, 17) xor ROTRight256(X, 19) xor (X shr 10);
end;

function SIG0512(X: TUInt64): TUInt64;
begin
  Result := ROTRight512(X, 28) xor ROTRight512(X, 34) xor ROTRight512(X, 39);
end;

function SIG1512(X: TUInt64): TUInt64;
begin
  Result := ROTRight512(X, 14) xor ROTRight512(X, 18) xor ROTRight512(X, 41);
end;

function Gamma0512(X: TUInt64): TUInt64;
begin
  Result := ROTRight512(X, 1) xor ROTRight512(X, 8) xor SHR512(X, 7);
end;

function Gamma1512(X: TUInt64): TUInt64;
begin
  Result := ROTRight512(X, 19) xor ROTRight512(X, 61) xor SHR512(X, 6);
end;

procedure SHA256Transform(var Context: TSHA256Context; Data: PAnsiChar);
var
  A, B, C, D, E, F, G, H, T1, T2: DWORD;
  M: array[0..63] of DWORD;
  I, J: Integer;
begin
  I := 0;
  J := 0;
  while I < 16 do
  begin
    M[I] := (DWORD(Data[J]) shl 24) or (DWORD(Data[J + 1]) shl 16) or (DWORD(Data
      [J + 2]) shl 8) or DWORD(Data[J + 3]);
    Inc(I);
    Inc(J, 4);
  end;

  while I < 64 do
  begin
    M[I] := SIG1256(M[I - 2]) + M[I - 7] + SIG0256(M[I - 15]) + M[I - 16];
    Inc(I);
  end;

  A := Context.State[0];
  B := Context.State[1];
  C := Context.State[2];
  D := Context.State[3];
  E := Context.State[4];
  F := Context.State[5];
  G := Context.State[6];
  H := Context.State[7];

  I := 0;
  while I < 64 do
  begin
    T1 := H + EP1256(E) + CH256(E, F, G) + KEYS256[I] + M[I];
    T2 := EP0256(A) + MAJ256(A, B, C);
    H := G;
    G := F;
    F := E;
    E := D + T1;
    D := C;
    C := B;
    B := A;
    A := T1 + T2;
    Inc(I);
  end;

  Context.State[0] := Context.State[0] + A;
  Context.State[1] := Context.State[1] + B;
  Context.State[2] := Context.State[2] + C;
  Context.State[3] := Context.State[3] + D;
  Context.State[4] := Context.State[4] + E;
  Context.State[5] := Context.State[5] + F;
  Context.State[6] := Context.State[6] + G;
  Context.State[7] := Context.State[7] + H;
end;

procedure SHA512Transform(var Context: TSHA512Context; Data: PAnsiChar);
var
  A, B, C, D, E, F, G, H, T1, T2: TUInt64;
  M: array[0..79] of TUInt64;
  I, J: Integer;
begin
  I := 0;
  J := 0;
  while I < 16 do
  begin
    M[I] := (TUInt64(Data[J]) shl 56) or (TUInt64(Data[J + 1]) shl 48) or
      (TUInt64(Data[J + 2]) shl 40) or (TUInt64(Data[J + 3]) shl 32) or
      (TUInt64(Data[J + 4]) shl 24) or (TUInt64(Data[J + 5]) shl 16) or
      (TUInt64(Data[J + 6]) shl 8) or TUInt64(Data[J + 7]);
    Inc(I);
    Inc(J, 8);
  end;

  while I < 80 do
  begin
    M[I] := Gamma1512(M[I - 2]) + M[I - 7] + Gamma0512(M[I - 15]) + M[I - 16];
    Inc(I);
  end;

  A := Context.State[0];
  B := Context.State[1];
  C := Context.State[2];
  D := Context.State[3];
  E := Context.State[4];
  F := Context.State[5];
  G := Context.State[6];
  H := Context.State[7];

  I := 0;
  while I < 80 do
  begin
    T1 := H + SIG1512(E) + CH512(E, F, G) + KEYS512[I] + M[I];
    T2 := SIG0512(A) + MAJ512(A, B, C);
    H := G;
    G := F;
    F := E;
    E := D + T1;
    D := C;
    C := B;
    B := A;
    A := T1 + T2;
    Inc(I);
  end;

  Context.State[0] := Context.State[0] + A;
  Context.State[1] := Context.State[1] + B;
  Context.State[2] := Context.State[2] + C;
  Context.State[3] := Context.State[3] + D;
  Context.State[4] := Context.State[4] + E;
  Context.State[5] := Context.State[5] + F;
  Context.State[6] := Context.State[6] + G;
  Context.State[7] := Context.State[7] + H;
end;

procedure SHA224Init(var Context: TSHA224Context);
begin
  Context.DataLen := 0;
  Context.BitLen := 0;
  Context.State[0] := $C1059ED8;
  Context.State[1] := $367CD507;
  Context.State[2] := $3070DD17;
  Context.State[3] := $F70E5939;
  Context.State[4] := $FFC00B31;
  Context.State[5] := $68581511;
  Context.State[6] := $64F98FA7;
  Context.State[7] := $BEFA4FA4;
  FillChar(Context.Data, SizeOf(Context.Data), 0);
end;

procedure SHA224Update(var Context: TSHA224Context; Buffer: PAnsiChar; Len: Cardinal);
begin
  SHA256Update(Context, Buffer, Len);
end;

procedure SHA256UpdateW(var Context: TSHA256Context; Buffer: PWideChar; Len: LongWord); forward;

procedure SHA224UpdateW(var Context: TSHA224Context; Buffer: PWideChar; Len: LongWord);
begin
  SHA256UpdateW(Context, Buffer, Len);
end;

procedure SHA224Final(var Context: TSHA224Context; var Digest: TSHA224Digest);
var
  Dig: TSHA256Digest;
begin
  SHA256Final(Context, Dig);
  CopyMemory(@Digest[0], @Dig[0], SizeOf(TSHA224Digest));
end;

procedure SHA256Init(var Context: TSHA256Context);
begin
  Context.DataLen := 0;
  Context.BitLen := 0;
  Context.State[0] := $6A09E667;
  Context.State[1] := $BB67AE85;
  Context.State[2] := $3C6EF372;
  Context.State[3] := $A54FF53A;
  Context.State[4] := $510E527F;
  Context.State[5] := $9B05688C;
  Context.State[6] := $1F83D9AB;
  Context.State[7] := $5BE0CD19;
  FillChar(Context.Data, SizeOf(Context.Data), 0);
end;

procedure SHA256Update(var Context: TSHA256Context; Buffer: PAnsiChar; Len: Cardinal);
var
  I: Integer;
begin
  for I := 0 to Len - 1 do
  begin
    Context.Data[Context.DataLen] := Byte(Buffer[I]);
    Inc(Context.DataLen);
    if Context.DataLen = 64 then
    begin
      SHA256Transform(Context, @Context.Data[0]);
      Context.BitLen := Context.BitLen + 512;
      Context.DataLen := 0;
    end;
  end;
end;

procedure SHA256UpdateW(var Context: TSHA256Context; Buffer: PWideChar; Len: LongWord);
var
  Content: PAnsiChar;
  iLen: Cardinal;
begin
  GetMem(Content, Len * SizeOf(WideChar));
  try
    iLen := WideCharToMultiByte(0, 0, Buffer, Len, // 代码页默认用 0
      PAnsiChar(Content), Len * SizeOf(WideChar), nil, nil);
    SHA256Update(Context, Content, iLen);
  finally
    FreeMem(Content);
  end;
end;

procedure SHA256Final(var Context: TSHA256Context; var Digest: TSHA256Digest);
var
  I: Integer;
begin
  I := Context.DataLen;
  Context.Data[I] := $80;
  Inc(I);

  if Context.Datalen < 56 then
  begin
    while I < 56 do
    begin
      Context.Data[I] := 0;
      Inc(I);
    end;
  end
  else
  begin
    while I < 64 do
    begin
      Context.Data[I] := 0;
      Inc(I);
    end;

    SHA256Transform(Context, @(Context.Data[0]));
    FillChar(Context.Data, 56, 0);
  end;

  Context.BitLen := Context.BitLen + Context.DataLen * 8;
  Context.Data[63] := Context.Bitlen;
  Context.Data[62] := Context.Bitlen shr 8;
  Context.Data[61] := Context.Bitlen shr 16;
  Context.Data[60] := Context.Bitlen shr 24;
  Context.Data[59] := Context.Bitlen shr 32;
  Context.Data[58] := Context.Bitlen shr 40;
  Context.Data[57] := Context.Bitlen shr 48;
  Context.Data[56] := Context.Bitlen shr 56;
  SHA256Transform(Context, @(Context.Data[0]));

  for I := 0 to 3 do
  begin
    Digest[I] := (Context.State[0] shr (24 - I * 8)) and $000000FF;
    Digest[I + 4] := (Context.State[1] shr (24 - I * 8)) and $000000FF;
    Digest[I + 8] := (Context.State[2] shr (24 - I * 8)) and $000000FF;
    Digest[I + 12] := (Context.State[3] shr (24 - I * 8)) and $000000FF;
    Digest[I + 16] := (Context.State[4] shr (24 - I * 8)) and $000000FF;
    Digest[I + 20] := (Context.State[5] shr (24 - I * 8)) and $000000FF;
    Digest[I + 24] := (Context.State[6] shr (24 - I * 8)) and $000000FF;
    Digest[I + 28] := (Context.State[7] shr (24 - I * 8)) and $000000FF;
  end;
end;

procedure SHA384Init(var Context: TSHA384Context);
begin
  Context.DataLen := 0;
  Context.BitLen := 0;
  Context.State[0] := $CBBB9D5DC1059ED8;
  Context.State[1] := $629A292A367CD507;
  Context.State[2] := $9159015A3070DD17;
  Context.State[3] := $152FECD8F70E5939;
  Context.State[4] := $67332667FFC00B31;
  Context.State[5] := $8EB44A8768581511;
  Context.State[6] := $DB0C2E0D64F98FA7;
  Context.State[7] := $47B5481DBEFA4FA4;
  FillChar(Context.Data, SizeOf(Context.Data), 0);
end;

procedure SHA384Update(var Context: TSHA384Context; Buffer: PAnsiChar; Len: Cardinal);
begin
  SHA512Update(Context, Buffer, Len);
end;

procedure SHA512UpdateW(var Context: TSHA512Context; Buffer: PWideChar; Len: LongWord); forward;

procedure SHA384UpdateW(var Context: TSHA384Context; Buffer: PWideChar; Len: LongWord);
begin
  SHA512UpdateW(Context, Buffer, Len);
end;

procedure SHA384Final(var Context: TSHA384Context; var Digest: TSHA384Digest);
var
  Dig: TSHA512Digest;
begin
  SHA512Final(Context, Dig);
  CopyMemory(@Digest[0], @Dig[0], SizeOf(TSHA384Digest));
end;

procedure SHA512Init(var Context: TSHA512Context);
begin
  Context.DataLen := 0;
  Context.BitLen := 0;
  Context.State[0] := $6A09E667F3BCC908;
  Context.State[1] := $BB67AE8584CAA73B;
  Context.State[2] := $3C6EF372FE94F82B;
  Context.State[3] := $A54FF53A5F1D36F1;
  Context.State[4] := $510E527FADE682D1;
  Context.State[5] := $9B05688C2B3E6C1F;
  Context.State[6] := $1F83D9ABFB41BD6B;
  Context.State[7] := $5BE0CD19137E2179;
  FillChar(Context.Data, SizeOf(Context.Data), 0);
end;

procedure SHA512Update(var Context: TSHA512Context; Buffer: PAnsiChar; Len: Cardinal);
var
  I: Integer;
begin
  for I := 0 to Len - 1 do
  begin
    Context.Data[Context.DataLen] := Byte(Buffer[I]);
    Inc(Context.DataLen);
    if Context.DataLen = 128 then
    begin
      SHA512Transform(Context, @Context.Data[0]);
      Context.BitLen := Context.BitLen + 1024;
      Context.DataLen := 0;
    end;
  end;
end;

procedure SHA512UpdateW(var Context: TSHA512Context; Buffer: PWideChar; Len: LongWord);
var
  Content: PAnsiChar;
  iLen: Cardinal;
begin
  GetMem(Content, Len * SizeOf(WideChar));
  try
    iLen := WideCharToMultiByte(0, 0, Buffer, Len, // 代码页默认用 0
      PAnsiChar(Content), Len * SizeOf(WideChar), nil, nil);
    SHA512Update(Context, Content, iLen);
  finally
    FreeMem(Content);
  end;
end;

procedure SHA512Final(var Context: TSHA512Context; var Digest: TSHA512Digest);
var
  I: Integer;
begin
  I := Context.DataLen;
  Context.Data[I] := $80;
  Inc(I);

  if Context.Datalen < 112 then
  begin
    while I < 112 do
    begin
      Context.Data[I] := 0;
      Inc(I);
    end;
  end
  else
  begin
    while I < 128 do
    begin
      Context.Data[I] := 0;
      Inc(I);
    end;

    SHA512Transform(Context, @(Context.Data[0]));
    FillChar(Context.Data, 120, 0);
  end;

  Context.BitLen := Context.BitLen + Context.DataLen * 8;
  Context.Data[127] := Context.Bitlen;
  Context.Data[126] := Context.Bitlen shr 8;
  Context.Data[125] := Context.Bitlen shr 16;
  Context.Data[124] := Context.Bitlen shr 24;
  Context.Data[123] := Context.Bitlen shr 32;
  Context.Data[122] := Context.Bitlen shr 40;
  Context.Data[121] := Context.Bitlen shr 48;
  Context.Data[120] := Context.Bitlen shr 56;
  SHA512Transform(Context, @(Context.Data[0]));

  for I := 0 to 7 do
  begin
    Digest[I] := (Context.State[0] shr (56 - I * 8)) and $000000FF;
    Digest[I + 8] := (Context.State[1] shr (56 - I * 8)) and $000000FF;
    Digest[I + 16] := (Context.State[2] shr (56 - I * 8)) and $000000FF;
    Digest[I + 24] := (Context.State[3] shr (56 - I * 8)) and $000000FF;
    Digest[I + 32] := (Context.State[4] shr (56 - I * 8)) and $000000FF;
    Digest[I + 40] := (Context.State[5] shr (56 - I * 8)) and $000000FF;
    Digest[I + 48] := (Context.State[6] shr (56 - I * 8)) and $000000FF;
    Digest[I + 56] := (Context.State[7] shr (56 - I * 8)) and $000000FF;
  end;
end;

// 对数据块进行SHA224转换
function SHA224Buffer(const Buffer; Count: LongWord): TSHA224Digest;
var
  Context: TSHA224Context;
begin
  SHA224Init(Context);
  SHA224Update(Context, PAnsiChar(Buffer), Count);
  SHA224Final(Context, Result);
end;

// 对数据块进行SHA256转换
function SHA256Buffer(const Buffer; Count: LongWord): TSHA256Digest;
var
  Context: TSHA256Context;
begin
  SHA256Init(Context);
  SHA256Update(Context, PAnsiChar(Buffer), Count);
  SHA256Final(Context, Result);
end;

// 对数据块进行SHA384转换
function SHA384Buffer(const Buffer; Count: LongWord): TSHA384Digest;
var
  Context: TSHA384Context;
begin
  SHA384Init(Context);
  SHA384Update(Context, PAnsiChar(Buffer), Count);
  SHA384Final(Context, Result);
end;

// 对数据块进行SHA512转换
function SHA512Buffer(const Buffer; Count: LongWord): TSHA512Digest;
var
  Context: TSHA512Context;
begin
  SHA512Init(Context);
  SHA512Update(Context, PAnsiChar(Buffer), Count);
  SHA512Final(Context, Result);
end;

// 对String类型数据进行SHA224转换
function SHA224String(const Str: string): TSHA224Digest;
var
  Context: TSHA224Context;
begin
  SHA224Init(Context);
  SHA224Update(Context, PAnsiChar({$IFDEF UNICODE}AnsiString{$ENDIF}(Str)),
    Length(Str) * SizeOf(Char));
  SHA224Final(Context, Result);
end;

// 对String类型数据进行SHA256转换
function SHA256String(const Str: string): TSHA256Digest;
var
  Context: TSHA256Context;
begin
  SHA256Init(Context);
  SHA256Update(Context, PAnsiChar({$IFDEF UNICODE}AnsiString{$ENDIF}(Str)),
    Length(Str) * SizeOf(Char));
  SHA256Final(Context, Result);
end;

// 对String类型数据进行SHA384转换
function SHA384String(const Str: string): TSHA384Digest;
var
  Context: TSHA384Context;
begin
  SHA384Init(Context);
  SHA384Update(Context, PAnsiChar({$IFDEF UNICODE}AnsiString{$ENDIF}(Str)),
    Length(Str) * SizeOf(Char));
  SHA384Final(Context, Result);
end;

// 对String类型数据进行SHA512转换
function SHA512String(const Str: string): TSHA512Digest;
var
  Context: TSHA512Context;
begin
  SHA512Init(Context);
  SHA512Update(Context, PAnsiChar({$IFDEF UNICODE}AnsiString{$ENDIF}(Str)),
    Length(Str) * SizeOf(Char));
  SHA512Final(Context, Result);
end;

// 对AnsiString类型数据进行SHA224转换
function SHA224StringA(const Str: AnsiString): TSHA224Digest;
var
  Context: TSHA224Context;
begin
  SHA224Init(Context);
  SHA224Update(Context, PAnsiChar(Str), Length(Str));
  SHA224Final(Context, Result);
end;

// 对WideString类型数据进行SHA224转换
function SHA224StringW(const Str: WideString): TSHA224Digest;
var
  Context: TSHA224Context;
begin
  SHA224Init(Context);
  SHA224UpdateW(Context, PWideChar(Str), Length(Str));
  SHA224Final(Context, Result);
end;

// 对AnsiString类型数据进行SHA256转换
function SHA256StringA(const Str: AnsiString): TSHA256Digest;
var
  Context: TSHA256Context;
begin
  SHA256Init(Context);
  SHA256Update(Context, PAnsiChar(Str), Length(Str));
  SHA256Final(Context, Result);
end;

// 对WideString类型数据进行SHA256转换
function SHA256StringW(const Str: WideString): TSHA256Digest;
var
  Context: TSHA256Context;
begin
  SHA256Init(Context);
  SHA256UpdateW(Context, PWideChar(Str), Length(Str));
  SHA256Final(Context, Result);
end;

// 对AnsiString类型数据进行SHA256转换
function SHA384StringA(const Str: AnsiString): TSHA384Digest;
var
  Context: TSHA384Context;
begin
  SHA384Init(Context);
  SHA384Update(Context, PAnsiChar(Str), Length(Str));
  SHA384Final(Context, Result);
end;

// 对WideString类型数据进行SHA256转换
function SHA384StringW(const Str: WideString): TSHA384Digest;
var
  Context: TSHA384Context;
begin
  SHA384Init(Context);
  SHA384UpdateW(Context, PWideChar(Str), Length(Str));
  SHA384Final(Context, Result);
end;

// 对AnsiString类型数据进行SHA512转换
function SHA512StringA(const Str: AnsiString): TSHA512Digest;
var
  Context: TSHA512Context;
begin
  SHA512Init(Context);
  SHA512Update(Context, PAnsiChar(Str), Length(Str));
  SHA512Final(Context, Result);
end;

// 对WideString类型数据进行SHA256转换
function SHA512StringW(const Str: WideString): TSHA512Digest;
var
  Context: TSHA512Context;
begin
  SHA512Init(Context);
  SHA512UpdateW(Context, PWideChar(Str), Length(Str));
  SHA512Final(Context, Result);
end;

function InternalSHAStream(Stream: TStream; const BufSize: Cardinal; var D:
  TSHAGeneralDigest; SHAType: TShaType; CallBack: TSHACalcProgressFunc = nil): Boolean;
var
  Buf: PAnsiChar;
  BufLen: Cardinal;
  Size: Int64;
  ReadBytes: Cardinal;
  TotalBytes: Int64;
  SavePos: Int64;
  CancelCalc: Boolean;

  Context224: TSHA224Context;
  Context256: TSHA256Context;
  Context384: TSHA384Context;
  Context512: TSHA512Context;
  Dig224: TSHA224Digest;
  Dig256: TSHA256Digest;
  Dig384: TSHA384Digest;
  Dig512: TSHA512Digest;

  procedure _SHAInit;
  begin
    case SHAType of
      stSHA224:
        SHA224Init(Context224);
      stSHA256:
        SHA256Init(Context256);
      stSHA384:
        SHA384Init(Context384);
      stSHA512:
        SHA512Init(Context512);
    end;
  end;

  procedure _SHAUpdate;
  begin
    case SHAType of
      stSHA224:
        SHA224Update(Context224, Buf, ReadBytes);
      stSHA256:
        SHA256Update(Context256, Buf, ReadBytes);
      stSHA384:
        SHA384Update(Context384, Buf, ReadBytes);
      stSHA512:
        SHA512Update(Context512, Buf, ReadBytes);
    end;
  end;

  procedure _SHAFinal;
  begin
    case SHAType of
      stSHA224:
        SHA224Final(Context224, Dig224);
      stSHA256:
        SHA256Final(Context256, Dig256);
      stSHA384:
        SHA384Final(Context384, Dig384);
      stSHA512:
        SHA512Final(Context512, Dig512);
    end;
  end;

  procedure _CopyResult;
  begin
    case SHAType of
      stSHA224:
        CopyMemory(@D[0], @Dig224[0], SizeOf(TSHA224Digest));
      stSHA256:
        CopyMemory(@D[0], @Dig256[0], SizeOf(TSHA256Digest));
      stSHA384:
        CopyMemory(@D[0], @Dig384[0], SizeOf(TSHA384Digest));
      stSHA512:
        CopyMemory(@D[0], @Dig512[0], SizeOf(TSHA512Digest));
    end;
  end;

begin
  Result := False;
  Size := Stream.Size;
  SavePos := Stream.Position;
  TotalBytes := 0;
  if Size = 0 then
    Exit;
  if Size < BufSize then
    BufLen := Size
  else
    BufLen := BufSize;

  CancelCalc := False;
  _SHAInit;
 
  GetMem(Buf, BufLen);
  try
    Stream.Seek(0, soFromBeginning);
    repeat
      ReadBytes := Stream.Read(Buf^, BufLen);
      if ReadBytes <> 0 then
      begin
        Inc(TotalBytes, ReadBytes);
        _SHAUpdate;

        if Assigned(CallBack) then
        begin
          CallBack(Size, TotalBytes, CancelCalc);
          if CancelCalc then
            Exit;
        end;
      end;
    until (ReadBytes = 0) or (TotalBytes = Size);
    _SHAFinal;
    _CopyResult;
    Result := True;
  finally
    FreeMem(Buf, BufLen);
    Stream.Position := SavePos;
  end;
end;

// 对指定流进行SHA224计算
function SHA224Stream(Stream: TStream; CallBack: TSHACalcProgressFunc = nil):
  TSHA224Digest;
var
  Dig: TSHAGeneralDigest;
begin
  InternalSHAStream(Stream, 4096 * 1024, Dig, stSHA224, CallBack);
  CopyMemory(@Result[0], @Dig[0], SizeOf(TSHA224Digest));
end;

// 对指定流进行SHA256计算
function SHA256Stream(Stream: TStream; CallBack: TSHACalcProgressFunc = nil):
  TSHA256Digest;
var
  Dig: TSHAGeneralDigest;
begin
  InternalSHAStream(Stream, 4096 * 1024, Dig, stSHA256, CallBack);
  CopyMemory(@Result[0], @Dig[0], SizeOf(TSHA256Digest));
end;

// 对指定流进行SHA384计算
function SHA384Stream(Stream: TStream; CallBack: TSHACalcProgressFunc = nil):
  TSHA384Digest;
var
  Dig: TSHAGeneralDigest;
begin
  InternalSHAStream(Stream, 4096 * 1024, Dig, stSHA384, CallBack);
  CopyMemory(@Result[0], @Dig[0], SizeOf(TSHA384Digest));
end;

// 对指定流进行SHA512计算
function SHA512Stream(Stream: TStream; CallBack: TSHACalcProgressFunc = nil):
  TSHA512Digest;
var
  Dig: TSHAGeneralDigest;
begin
  InternalSHAStream(Stream, 4096 * 1024, Dig, stSHA512, CallBack);
  CopyMemory(@Result[0], @Dig[0], SizeOf(TSHA512Digest));
end;

function FileSizeIsLargeThanMax(const AFileName: string; out IsEmpty: Boolean): Boolean;
var
  H: THandle;
  Info: BY_HANDLE_FILE_INFORMATION;
  Rec: Int64Rec;
begin
  Result := False;
  IsEmpty := False;
  H := CreateFile(PChar(AFileName), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, 0, 0);
  if H = INVALID_HANDLE_VALUE then
    Exit;
  try
    if not GetFileInformationByHandle(H, Info) then
      Exit;
  finally
    CloseHandle(H);
  end;
  Rec.Lo := Info.nFileSizeLow;
  Rec.Hi := Info.nFileSizeHigh;
  Result := (Rec.Hi > 0) or (Rec.Lo > MAX_FILE_SIZE);
  IsEmpty := (Rec.Hi = 0) and (Rec.Lo = 0);
end;

function InternalSHAFile(const FileName: string; SHAType: TSHAType;
  CallBack: TSHACalcProgressFunc): TSHAGeneralDigest;
var
  Context224: TSHA224Context;
  Context256: TSHA256Context;
  Context384: TSHA384Context;
  Context512: TSHA512Context;
  Dig224: TSHA224Digest;
  Dig256: TSHA256Digest;
  Dig384: TSHA384Digest;
  Dig512: TSHA512Digest;

  FileHandle: THandle;
  MapHandle: THandle;
  ViewPointer: Pointer;
  Stream: TStream;
  FileIsZeroSize: Boolean;

  procedure _SHAInit;
  begin
    case SHAType of
      stSHA224:
        SHA224Init(Context224);
      stSHA256:
        SHA256Init(Context256);
      stSHA384:
        SHA384Init(Context384);
      stSHA512:
        SHA512Init(Context512);
    end;
  end;

  procedure _SHAUpdate;
  begin
    case SHAType of
      stSHA224:
        SHA224Update(Context224, ViewPointer, GetFileSize(FileHandle, nil));
      stSHA256:
        SHA256Update(Context256, ViewPointer, GetFileSize(FileHandle, nil));
      stSHA384:
        SHA384Update(Context384, ViewPointer, GetFileSize(FileHandle, nil));
      stSHA512:
        SHA512Update(Context512, ViewPointer, GetFileSize(FileHandle, nil));
    end;
  end;

  procedure _SHAFinal;
  begin
    case SHAType of
      stSHA224:
        SHA224Final(Context224, Dig224);
      stSHA256:
        SHA256Final(Context256, Dig256);
      stSHA384:
        SHA384Final(Context384, Dig384);
      stSHA512:
        SHA512Final(Context512, Dig512);
    end;
  end;

  procedure _CopyResult(var D: TSHAGeneralDigest);
  begin
    case SHAType of
      stSHA224:
        CopyMemory(@D[0], @Dig224[0], SizeOf(TSHA224Digest));
      stSHA256:
        CopyMemory(@D[0], @Dig256[0], SizeOf(TSHA256Digest));
      stSHA384:
        CopyMemory(@D[0], @Dig384[0], SizeOf(TSHA384Digest));
      stSHA512:
        CopyMemory(@D[0], @Dig512[0], SizeOf(TSHA512Digest));
    end;
  end;

begin
  FileIsZeroSize := False;
  if FileSizeIsLargeThanMax(FileName, FileIsZeroSize) then
  begin
    // 大于 2G 的文件可能 Map 失败，采用流方式循环处理
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      InternalSHAStream(Stream, 4096 * 1024, Result, SHAType, CallBack);
    finally
      Stream.Free;
    end;
  end
  else
  begin
    _SHAInit;
    FileHandle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ or
      FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or
      FILE_FLAG_SEQUENTIAL_SCAN, 0);
    if FileHandle <> INVALID_HANDLE_VALUE then
    begin
      try
        MapHandle := CreateFileMapping(FileHandle, nil, PAGE_READONLY, 0, 0, nil);
        if MapHandle <> 0 then
        begin
          try
            ViewPointer := MapViewOfFile(MapHandle, FILE_MAP_READ, 0, 0, 0);
            if ViewPointer <> nil then
            begin
              try
                _SHAUpdate;
              finally
                UnmapViewOfFile(ViewPointer);
              end;
            end
            else
            begin
              raise Exception.Create('MapViewOfFile Failed. ' + IntToStr(GetLastError));
            end;
          finally
            CloseHandle(MapHandle);
          end;
        end
        else
        begin
          if not FileIsZeroSize then
            raise Exception.Create('CreateFileMapping Failed. ' + IntToStr(GetLastError));
        end;
      finally
        CloseHandle(FileHandle);
      end;
    end;
    _SHAFinal;
    _CopyResult(Result);
  end;
end;

// 对指定文件数据进行SHA224转换
function SHA224File(const FileName: string; CallBack: TSHACalcProgressFunc):
  TSHA224Digest;
var
  Dig: TSHAGeneralDigest;
begin
  Dig := InternalSHAFile(FileName, stSHA224, CallBack);
  CopyMemory(@Result[0], @Dig[0], SizeOf(TSHA224Digest));
end;

// 对指定文件数据进行SHA256转换
function SHA256File(const FileName: string; CallBack: TSHACalcProgressFunc):
  TSHA256Digest;
var
  Dig: TSHAGeneralDigest;
begin
  Dig := InternalSHAFile(FileName, stSHA256, CallBack);
  CopyMemory(@Result[0], @Dig[0], SizeOf(TSHA256Digest));
end;

// 对指定文件数据进行SHA384转换
function SHA384File(const FileName: string; CallBack: TSHACalcProgressFunc):
  TSHA384Digest;
var
  Dig: TSHAGeneralDigest;
begin
  Dig := InternalSHAFile(FileName, stSHA384, CallBack);
  CopyMemory(@Result[0], @Dig[0], SizeOf(TSHA384Digest));
end;

// 对指定文件数据进行SHA512转换
function SHA512File(const FileName: string; CallBack: TSHACalcProgressFunc):
  TSHA512Digest;
var
  Dig: TSHAGeneralDigest;
begin
  Dig := InternalSHAFile(FileName, stSHA512, CallBack);
  CopyMemory(@Result[0], @Dig[0], SizeOf(TSHA512Digest));
end;

const
  Digits: array[0..15] of AnsiChar = ('0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');

// 以十六进制格式输出SHA224计算值
function SHA224Print(const Digest: TSHA224Digest): string;
var
  I: Byte;
begin
  Result := '';
  for I := 0 to 27 do
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}(Digits[(Digest[I] shr 4)
      and $0F] + Digits[Digest[I] and $0F]);
end;

// 以十六进制格式输出SHA256计算值
function SHA256Print(const Digest: TSHA256Digest): string;
var
  I: Byte;
begin
  Result := '';
  for I := 0 to 31 do
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}(Digits[(Digest[I] shr 4)
      and $0F] + Digits[Digest[I] and $0F]);
end;

// 以十六进制格式输出SHA384计算值
function SHA384Print(const Digest: TSHA384Digest): string;
var
  I: Byte;
begin
  Result := '';
  for I := 0 to 47 do
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}(Digits[(Digest[I] shr 4)
      and $0F] + Digits[Digest[I] and $0F]);
end;

// 以十六进制格式输出SHA512计算值
function SHA512Print(const Digest: TSHA512Digest): string;
var
  I: Byte;
begin
  Result := '';
  for I := 0 to 63 do
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}(Digits[(Digest[I] shr 4)
      and $0F] + Digits[Digest[I] and $0F]);
end;

// 比较两个SHA224计算值是否相等
function SHA224Match(const D1, D2: TSHA224Digest): Boolean;
var
  I: Byte;
begin
  I := 0;
  Result := True;
  while Result and (I < 28) do
  begin
    Result := D1[I] = D2[I];
    Inc(I);
  end;
end;

// 比较两个SHA256计算值是否相等
function SHA256Match(const D1, D2: TSHA256Digest): Boolean;
var
  I: Byte;
begin
  I := 0;
  Result := True;
  while Result and (I < 32) do
  begin
    Result := D1[I] = D2[I];
    Inc(I);
  end;
end;

// 比较两个SHA384计算值是否相等
function SHA384Match(const D1, D2: TSHA384Digest): Boolean;
var
  I: Byte;
begin
  I := 0;
  Result := True;
  while Result and (I < 48) do
  begin
    Result := D1[I] = D2[I];
    Inc(I);
  end;
end;

// 比较两个SHA512计算值是否相等
function SHA512Match(const D1, D2: TSHA512Digest): Boolean;
var
  I: Byte;
begin
  I := 0;
  Result := True;
  while Result and (I < 64) do
  begin
    Result := D1[I] = D2[I];
    Inc(I);
  end;
end;

// SHA224计算值转 string
function SHA224DigestToStr(aDig: TSHA224Digest): string;
var
  I: Integer;
begin
  SetLength(Result, 28);
  for I := 1 to 28 do
    Result[I] := Chr(aDig[I - 1]);
end;

// SHA256计算值转 string
function SHA256DigestToStr(aDig: TSHA256Digest): string;
var
  I: Integer;
begin
  SetLength(Result, 32);
  for I := 1 to 32 do
    Result[I] := Chr(aDig[I - 1]);
end;

// SHA384计算值转 string
function SHA384DigestToStr(aDig: TSHA384Digest): string;
var
  I: Integer;
begin
  SetLength(Result, 48);
  for I := 1 to 48 do
    Result[I] := Chr(aDig[I - 1]);
end;

// SHA512计算值转 string
function SHA512DigestToStr(aDig: TSHA512Digest): string;
var
  I: Integer;
begin
  SetLength(Result, 64);
  for I := 1 to 64 do
    Result[I] := Chr(aDig[I - 1]);
end;

procedure SHA224HmacInit(var Context: TSHA224Context; Key: PAnsiChar; KeyLength: Integer);
var
  I: Integer;
  Sum: TSHA224Digest;
begin
  if KeyLength > 64 then
  begin
    Sum := SHA224Buffer(Key, KeyLength);
    KeyLength := 28;
    Key := @(Sum[0]);
  end;

  FillChar(Context.Ipad, $36, 64);
  FillChar(Context.Opad, $5C, 64);

  for I := 0 to KeyLength - 1 do
  begin
    Context.Ipad[I] := Byte(Context.Ipad[I] xor Byte(Key[I]));
    Context.Opad[I] := Byte(Context.Opad[I] xor Byte(Key[I]));
  end;

  SHA224Init(Context);
  SHA224Update(Context, @(Context.Ipad[0]), 64);
end;

procedure SHA224HmacUpdate(var Context: TSHA224Context; Input: PAnsiChar; Length:
  LongWord);
begin
  SHA224Update(Context, Input, Length);
end;

procedure SHA224HmacFinal(var Context: TSHA224Context; var Output: TSHA224Digest);
var
  Len: Integer;
  TmpBuf: TSHA224Digest;
begin
  Len := 28;
  SHA224Final(Context, TmpBuf);
  SHA224Init(Context);
  SHA224Update(Context, @(Context.Opad[0]), 64);
  SHA224Update(Context, @(TmpBuf[0]), Len);
  SHA224Final(Context, Output);
end;

procedure SHA256HmacInit(var Context: TSHA256Context; Key: PAnsiChar; KeyLength: Integer);
var
  I: Integer;
  Sum: TSHA256Digest;
begin
  if KeyLength > 64 then
  begin
    Sum := SHA256Buffer(Key, KeyLength);
    KeyLength := 32;
    Key := @(Sum[0]);
  end;

  FillChar(Context.Ipad, $36, 64);
  FillChar(Context.Opad, $5C, 64);

  for I := 0 to KeyLength - 1 do
  begin
    Context.Ipad[I] := Byte(Context.Ipad[I] xor Byte(Key[I]));
    Context.Opad[I] := Byte(Context.Opad[I] xor Byte(Key[I]));
  end;

  SHA256Init(Context);
  SHA256Update(Context, @(Context.Ipad[0]), 64);
end;

procedure SHA256HmacUpdate(var Context: TSHA256Context; Input: PAnsiChar; Length:
  LongWord);
begin
  SHA256Update(Context, Input, Length);
end;

procedure SHA256HmacFinal(var Context: TSHA256Context; var Output: TSHA256Digest);
var
  Len: Integer;
  TmpBuf: TSHA256Digest;
begin
  Len := 32;
  SHA256Final(Context, TmpBuf);
  SHA256Init(Context);
  SHA256Update(Context, @(Context.Opad[0]), 64);
  SHA256Update(Context, @(TmpBuf[0]), Len);
  SHA256Final(Context, Output);
end;

procedure SHA224Hmac(Key: PAnsiChar; KeyLength: Integer; Input: PAnsiChar;
  Length: LongWord; var Output: TSHA224Digest);
var
  Context: TSHA224Context;
begin
  SHA224HmacInit(Context, Key, KeyLength);
  SHA224HmacUpdate(Context, Input, Length);
  SHA224HmacFinal(Context, Output);
end;

procedure SHA256Hmac(Key: PAnsiChar; KeyLength: Integer; Input: PAnsiChar;
  Length: LongWord; var Output: TSHA256Digest);
var
  Context: TSHA256Context;
begin
  SHA256HmacInit(Context, Key, KeyLength);
  SHA256HmacUpdate(Context, Input, Length);
  SHA256HmacFinal(Context, Output);
end;

procedure SHA384HmacInit(var Context: TSHA384Context; Key: PAnsiChar; KeyLength: Integer);
var
  I: Integer;
  Sum: TSHA384Digest;
begin
  if KeyLength > 128 then
  begin
    Sum := SHA384Buffer(Key, KeyLength);
    KeyLength := 48;
    Key := @(Sum[0]);
  end;

  FillChar(Context.Ipad, $36, 128);
  FillChar(Context.Opad, $5C, 128);

  for I := 0 to KeyLength - 1 do
  begin
    Context.Ipad[I] := Byte(Context.Ipad[I] xor Byte(Key[I]));
    Context.Opad[I] := Byte(Context.Opad[I] xor Byte(Key[I]));
  end;

  SHA384Init(Context);
  SHA384Update(Context, @(Context.Ipad[0]), 128);
end;

procedure SHA384HmacUpdate(var Context: TSHA384Context; Input: PAnsiChar; Length:
  LongWord);
begin
  SHA384Update(Context, Input, Length);
end;

procedure SHA384HmacFinal(var Context: TSHA384Context; var Output: TSHA384Digest);
var
  Len: Integer;
  TmpBuf: TSHA384Digest;
begin
  Len := 48;
  SHA384Final(Context, TmpBuf);
  SHA384Init(Context);
  SHA384Update(Context, @(Context.Opad[0]), 128);
  SHA384Update(Context, @(TmpBuf[0]), Len);
  SHA384Final(Context, Output);
end;

procedure SHA384Hmac(Key: PAnsiChar; KeyLength: Integer; Input: PAnsiChar;
  Length: LongWord; var Output: TSHA384Digest);
var
  Context: TSHA384Context;
begin
  SHA384HmacInit(Context, Key, KeyLength);
  SHA384HmacUpdate(Context, Input, Length);
  SHA384HmacFinal(Context, Output);
end;

procedure SHA512HmacInit(var Context: TSHA512Context; Key: PAnsiChar; KeyLength: Integer);
var
  I: Integer;
  Sum: TSHA512Digest;
begin
  if KeyLength > 128 then
  begin
    Sum := SHA512Buffer(Key, KeyLength);
    KeyLength := 64;
    Key := @(Sum[0]);
  end;

  FillChar(Context.Ipad, $36, 128);
  FillChar(Context.Opad, $5C, 128);

  for I := 0 to KeyLength - 1 do
  begin
    Context.Ipad[I] := Byte(Context.Ipad[I] xor Byte(Key[I]));
    Context.Opad[I] := Byte(Context.Opad[I] xor Byte(Key[I]));
  end;

  SHA512Init(Context);
  SHA512Update(Context, @(Context.Ipad[0]), 128);
end;

procedure SHA512HmacUpdate(var Context: TSHA512Context; Input: PAnsiChar; Length:
  LongWord);
begin
  SHA512Update(Context, Input, Length);
end;

procedure SHA512HmacFinal(var Context: TSHA512Context; var Output: TSHA512Digest);
var
  Len: Integer;
  TmpBuf: TSHA512Digest;
begin
  Len := 64;
  SHA512Final(Context, TmpBuf);
  SHA512Init(Context);
  SHA512Update(Context, @(Context.Opad[0]), 128);
  SHA512Update(Context, @(TmpBuf[0]), Len);
  SHA512Final(Context, Output);
end;

procedure SHA512Hmac(Key: PAnsiChar; KeyLength: Integer; Input: PAnsiChar;
  Length: LongWord; var Output: TSHA512Digest);
var
  Context: TSHA512Context;
begin
  SHA512HmacInit(Context, Key, KeyLength);
  SHA512HmacUpdate(Context, Input, Length);
  SHA512HmacFinal(Context, Output);
end;

end.

