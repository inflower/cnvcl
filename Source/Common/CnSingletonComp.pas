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

unit CnSingletonComp;
{* |<PRE>
================================================================================
* 软件名称：开发包基础库
* 单元名称：单实例组件实现单元
* 单元作者：Chinbo（Shenloqi）
*           刘啸 (liuxiao@cnpack.org)
* 备    注：该单元定义了单实例组件基类，有互斥机制，可用于多线程，代码类似于
*           实现单实例对象基类的 CnSingleton。
*           注意 TCnSingletonComponent 并非 TCnSingleton 的子类。
* 开发平台：PWinXP SP2 + Delphi 5
* 兼容测试：PWin9X/2000/XP + Delphi 6/7 C++Builder 6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 单元标识：$Id$
* 修改记录：2006.08.17
*                创建单元
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes;

type
  ECnSingletonException = class(Exception);

  TCnSingletonComponent = class(TComponent)
  private
    FForceFree, FAutoFree: Boolean;
    class function Singleton: TObject;
    procedure SetAutoFree(const Value: Boolean);
  protected
    class function RefCount: Cardinal;
    class function GetClassBaseOffsetStr: string; virtual;
  public
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;

    class procedure Lock;
    class procedure Unlock;

    procedure ForceFree;

    property AutoFree: Boolean read FAutoFree write SetAutoFree;
  end;

implementation

uses
  SyncObjs;

type
  PCnSingletonInfo = ^TCnSingletonInfo;
  TCnSingletonInfo = record
    RefCount: Cardinal;
    Instance: TObject;
  end;

  TCnSingletonCompList = class(TStringList)
  public
    procedure FreeAllSingletons;
  end;

var
  _SingletonList: TCnSingletonCompList;
  _Finalize: Boolean = False;
  _CriticalSection: TCriticalSection;

{ TCnSingletonComponent }

class function TCnSingletonComponent.NewInstance: TObject;
begin
  Result := Singleton;
end;

procedure TCnSingletonComponent.FreeInstance;
var
  i: Integer;
  tmpSingletonInfo: PCnSingletonInfo;
begin
  Lock;
  try
    i := _SingletonList.IndexOf(GetClassBaseOffsetStr);
    if i < 0 then begin
      inherited FreeInstance;
      Exit;
    end;

    tmpSingletonInfo := PCnSingletonInfo(_SingletonList.Objects[i]);
    if _Finalize or FForceFree then
    begin
      inherited FreeInstance;
      Dispose(PCnSingletonInfo(_SingletonList.Objects[i]));
      _SingletonList.Delete(i);
    end
    else
    begin
      if (tmpSingletonInfo^.RefCount > 1) then
        Dec(tmpSingletonInfo^.RefCount)
      else if FAutoFree then
      begin
        inherited FreeInstance;
        Dispose(PCnSingletonInfo(_SingletonList.Objects[i]));
        _SingletonList.Delete(i);
      end
      else
        tmpSingletonInfo^.RefCount := 0;
    end;
  finally
    Unlock;
  end;
end;

class procedure TCnSingletonComponent.Lock;
begin
  _CriticalSection.Enter;
end;

class procedure TCnSingletonComponent.Unlock;
begin
  _CriticalSection.Leave;
end;

class function TCnSingletonComponent.Singleton: TObject;
var
  i: Integer;
  tmpSingletonInfo: PCnSingletonInfo;
  tmpSingleton: TObject;
begin
  Lock;
  try
    tmpSingleton := nil;
    tmpSingletonInfo := nil;
    if _SingletonList.Find(GetClassBaseOffsetStr, i) then
    begin
      tmpSingletonInfo := PCnSingletonInfo(_SingletonList.Objects[i]);
      tmpSingleton := tmpSingletonInfo.Instance;
    end;
    if tmpSingleton = nil then
    begin
      New(tmpSingletonInfo);
      tmpSingleton := inherited NewInstance;
      tmpSingletonInfo.Instance := tmpSingleton;
      tmpSingletonInfo.RefCount := 0;
      _SingletonList.AddObject(GetClassBaseOffsetStr, TObject(tmpSingletonInfo));
    end;
    if tmpSingletonInfo <> nil then
      Inc(tmpSingletonInfo.RefCount);
    Result := tmpSingleton;
  finally
    Unlock;
  end;
end;

class function TCnSingletonComponent.RefCount: Cardinal;
var
  i: Integer;
  tmpSingletonInfo: PCnSingletonInfo;
begin
  Lock;
  try
    i := _SingletonList.IndexOf(GetClassBaseOffsetStr);
    if i >= 0 then
    begin
      tmpSingletonInfo := PCnSingletonInfo(_SingletonList.Objects[i]);
      Result := tmpSingletonInfo^.RefCount;
    end
    else
      Result := 0;
  finally
    Unlock;
  end;
end;

procedure TCnSingletonComponent.SetAutoFree(const Value: Boolean);
begin
  FAutoFree := Value;
  if Value then
  begin
    if RefCount <= 0 then
      Free;
  end;
end;

procedure TCnSingletonComponent.ForceFree;
begin
  FForceFree := True;
  Free;
end;

class function TCnSingletonComponent.GetClassBaseOffsetStr: string;
begin
  // ClassType 是类基址，转换成字符串作为唯一标识此类的字符串
  Result := IntToStr(Integer(Pointer(Self)));
end;

{ TCnSingletonCompList }

procedure TCnSingletonCompList.FreeAllSingletons;
var
  i: Integer;
  tmpSingleton: TObject;
begin
  _Finalize := True;
  for i := Count - 1 downto 0 do
  begin
    if Assigned(Objects[i]) then
    begin
      tmpSingleton := PCnSingletonInfo(Objects[i]).Instance;
      if tmpSingleton <> nil then
        FreeAndNil(tmpSingleton);
    end;
  end;
end;

initialization
  _CriticalSection := TCriticalSection.Create;
  _SingletonList := TCnSingletonCompList.Create;
  _SingletonList.Sorted := True;

finalization
  _SingletonList.Sorted := False;
  _SingletonList.FreeAllSingletons;
  FreeAndNil(_SingletonList);
  _CriticalSection.Free;

end.

