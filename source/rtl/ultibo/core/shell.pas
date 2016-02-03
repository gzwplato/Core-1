{
Ultibo Generic Shell unit.

Copyright (C) 2015 - SoftOz Pty Ltd.

Arch
====

 <All>

Boards
======

 <All>

Licence
=======

 LGPLv2.1 with static linking exception (See COPYING.modifiedLGPL.txt)
 
Credits
=======

 Information for this unit was obtained from:

 
References
==========


Shell
=====

}

{$mode delphi} {Default to Delphi compatible syntax}
{$H+}          {Default to AnsiString}
{$inline on}   {Allow use of Inline procedures}

unit Shell;

interface

uses GlobalConfig,GlobalConst,GlobalTypes,Platform,Threads,Devices,HeapManager,SysUtils,Classes,Ultibo,UltiboClasses,UltiboUtils,Authentication;

{==============================================================================}
{Global definitions}
{$INCLUDE GlobalDefines.inc}

{==============================================================================}
const
 {Shell specific constants}
 SHELL_LINE_END = Chr(13) + Chr(10); {CR LF}

 SHELL_DEFAULT_BANNER = 'Ultibo Core (Release: ' + ULTIBO_RELEASE_NAME + ' Version: ' + ULTIBO_RELEASE_VERSION + ' Date: ' + ULTIBO_RELEASE_DATE + ')';
 SHELL_DEFAULT_PROMPT = '>';
 SHELL_DEFAULT_ERROR = 'Huh?';
 
 {Shell Flag constants}
 SHELL_FLAG_NONE        = $00000000;
 SHELL_FLAG_CLEAR       = $00000001;
 SHELL_FLAG_SIZE        = $00000002;
 SHELL_FLAG_CURSOR      = $00000004;
 SHELL_FLAG_COLORS      = $00000008;
 SHELL_FLAG_COORDINATES = $00000010;
 
 {Shell Session Flag constants}
 SHELL_SESSION_FLAG_NONE = $00000000;
 
 {Shell Command Flag constants}
 SHELL_COMMAND_FLAG_NONE     = $00000000;
 SHELL_COMMAND_FLAG_HIDDEN   = $00000001;  {Hidden command, do not show in HELP or INFO}
 SHELL_COMMAND_FLAG_HELP     = $00000002;  {Command has HELP available}
 SHELL_COMMAND_FLAG_INFO     = $00000004;  {Command has INFO available}
 SHELL_COMMAND_FLAG_DEFAULT  = $00000008;  {Default command, pass unknown commands to this before showing error}
 SHELL_COMMAND_FLAG_EXTENDED = $00000008;  {Extended command, pass command name to command for extended handling}
 
 {Shell Alias Flag constants}
 SHELL_ALIAS_FLAG_NONE   = $00000000;
 SHELL_ALIAS_FLAG_HIDDEN = $00000001;  {Hidden alias, do not show in HELP or INFO}
 
 {Shell Command constants}
 SHELL_COMMAND_HELP     = 'HELP';
 SHELL_COMMAND_INFO     = 'INFO';
 SHELL_COMMAND_VER      = 'VER';
 SHELL_COMMAND_TIME     = 'TIME';
 SHELL_COMMAND_CLS      = 'CLS';
 SHELL_COMMAND_RESTART  = 'RESTART';
 SHELL_COMMAND_SHUTDOWN = 'SHUTDOWN';
 SHELL_COMMAND_CPU      = 'CPU';
 SHELL_COMMAND_UPTIME   = 'UPTIME';
 SHELL_COMMAND_WORKER   = 'WORKER';
 SHELL_COMMAND_THREAD   = 'THREAD';
 SHELL_COMMAND_MEMORY   = 'MEMORY';
 SHELL_COMMAND_DEVICE   = 'DEVICE';
 
 {Shell Alias constants}
 SHELL_ALIAS_HELP    = '?';
 SHELL_ALIAS_VERSION = 'VERSION';
 SHELL_ALIAS_CLEAR   = 'CLEAR';
 
 {Shell logging}
 SHELL_LOG_LEVEL_DEBUG     = LOG_LEVEL_DEBUG;  {Shell debugging messages}
 SHELL_LOG_LEVEL_INFO      = LOG_LEVEL_INFO;   {Shell informational messages}
 SHELL_LOG_LEVEL_ERROR     = LOG_LEVEL_ERROR;  {Shell error messages}
 SHELL_LOG_LEVEL_NONE      = LOG_LEVEL_NONE;   {No Shell messages}

var 
 SHELL_DEFAULT_LOG_LEVEL:LongWord = SHELL_LOG_LEVEL_DEBUG; //SHELL_LOG_LEVEL_INFO; {Minimum level for Shell messages.  Only messages with level greater than or equal to this will be printed} 
 
var 
 {Shell logging}
 SHELL_LOG_ENABLED:Boolean; 
 
{==============================================================================}
{type}
 {Shell specific types}

{==============================================================================}
type
 {Shell specific clases}
 TShell = class;
 TShellCommand = class;
 TShellManager = class(TObject)
 public
  {}
  constructor Create;
  destructor Destroy; override;
 private
  {Internal Variables}
  FLock:TCriticalSectionHandle; 
  
  FShells:TLinkedList;
  FCommands:TLinkedList;
  
  {Internal Methods}
  
 protected
  {Internal Variables}

  {Internal Methods}
  function AcquireLock:Boolean;
  function ReleaseLock:Boolean;
 public
  {Public Properties}

  {Public Methods}
  function GetShell(APrevious:TShell;ALock,AUnlock:Boolean):TShell;
  function FindShell(const AName:String):TShell;
  
  function RegisterShell(AShell:TShell):Boolean;
  function DeregisterShell(AShell:TShell):Boolean;
  
  function GetCommand(APrevious:TShellCommand;ALock,AUnlock:Boolean):TShellCommand;
  function FindCommand(const AName:String):TShellCommand;
  function DefaultCommand:TShellCommand;
  
  function RegisterCommand(ACommand:TShellCommand):Boolean;
  function DeregisterCommand(ACommand:TShellCommand):Boolean;
 end;
 
 TShellSession = class;
 //TShellHistory = class; //To Do
 TShell = class(TListObject)
 public
  {}
  constructor Create;
  destructor Destroy; override;
 private
  {Internal Variables}
  FManager:TShellManager;
  FAuthenticator:TAuthenticator;
  
  FLock:TCriticalSectionHandle;
  
  FSessions:TLinkedList;
  FCommands:TLinkedList;
  
  FBanner:String;
  FPrompt:String;
  FError:String;
  
  FName:String;
  FHash:LongWord;
  FFlags:LongWord;
  
  {Internal Methods}
  procedure SetAuthenticator(AAuthenticator:TAuthenticator);
  
  function GetBanner:String;
  procedure SetBanner(const ABanner:String); 
  function GetPrompt:String;
  procedure SetPrompt(const APrompt:String);
  function GetError:String;
  procedure SetError(const AError:String);
  
  function GetName:String;
  procedure SetName(const AName:String);
  procedure SetFlags(AFlags:LongWord);
 protected
  {Internal Variables}

  {Internal Methods}
  function AcquireLock:Boolean;
  function ReleaseLock:Boolean;
 public
  {Public Properties}
  property Manager:TShellManager read FManager;
  property Authenticator:TAuthenticator read FAuthenticator write SetAuthenticator;
  
  property Banner:String read GetBanner write SetBanner;
  property Prompt:String read GetPrompt write SetPrompt;
  property Error:String read GetError write SetError;
  
  property Name:String read GetName write SetName;
  property Hash:LongWord read FHash;
  property Flags:LongWord read FFlags write SetFlags;
  
  {Public Methods}
  function DoClear(ASession:TShellSession):Boolean; virtual;
  
  function DoBanner(ASession:TShellSession):Boolean; virtual;
  function DoPrompt(ASession:TShellSession):Boolean; virtual;
  function DoError(ASession:TShellSession):Boolean; virtual;
  
  function DoInput(ASession:TShellSession;var AInput:String):Boolean; virtual;
  
  function DoOutput(ASession:TShellSession;const AOutput:String):Boolean; virtual;
  function DoOutputEx(ASession:TShellSession;const AOutput:String;AReturn:Boolean):Boolean; virtual;
  
  function DoGetSize(ASession:TShellSession;var ARows,ACols:LongWord):Boolean; virtual;
  function DoSetSize(ASession:TShellSession;ARows,ACols:LongWord):Boolean; virtual;
  
  function DoGetCursor(ASession:TShellSession;var ARow,ACol:LongWord):Boolean; virtual;
  function DoSetCursor(ASession:TShellSession;ARow,ACol:LongWord):Boolean; virtual;

  function DoGetColors(ASession:TShellSession;var AForecolor,ABackcolor:LongWord):Boolean; virtual;
  function DoSetColors(ASession:TShellSession;AForecolor,ABackcolor:LongWord):Boolean; virtual;
  
  function DoGetCoordinates(ASession:TShellSession;var ARow,ACol:LongWord):Boolean; virtual;
  function DoSetCoordinates(ASession:TShellSession;ARow,ACol:LongWord):Boolean; virtual;
  
  function GetSession(APrevious:TShellSession;ALock,AUnlock:Boolean):TShellSession;
  function FindSession(AIdentifier:LongWord):TShellSession;
  
  function CreateSession(AIdentifier:LongWord):TShellSession;
  function DestroySession(ASession:TShellSession):Boolean;
  
  function RegisterSession(ASession:TShellSession):Boolean;
  function DeregisterSession(ASession:TShellSession):Boolean;
  
  function GetCommand(APrevious:TShellCommand;ALock,AUnlock:Boolean):TShellCommand;
  function FindCommand(const AName:String):TShellCommand;
  function DefaultCommand:TShellCommand;
  
  function RegisterCommand(ACommand:TShellCommand):Boolean;
  function DeregisterCommand(ACommand:TShellCommand):Boolean;
  
  function MatchCommand(const ACommand:String;var AContinue:Boolean):TShellCommand; virtual;
  function ProcessCommand(ASession:TShellSession;const ACommand:String):Boolean; virtual;
  
  function CommandName(const ACommand:String):String;
  function CommandSplit(const ACommand:String):TStrings;
  function CommandParse(const ACommand:String;var AName:String;var AParameters:TStrings):Boolean;
  function CommandIndex(AIndex:Integer;const ACommand:String):String;

  function ParameterIndex(AIndex:Integer;AParameters:TStrings):String;
  function ParameterValue(const AParameter:String;AParameters:TStrings):String;
  function ParameterExists(const AParameter:String;AParameters:TStrings):Boolean;

  function ParameterValueEx(const AParameter:String;AParameters:TStrings;APlus,AMinus:Boolean):String;
  function ParameterExistsEx(const AParameter:String;AParameters:TStrings;APlus,AMinus:Boolean):Boolean;
  
  function AddOutput(var AOutput:String;ACol:LongWord;const AValue:String):Boolean;
 end;
 
 TShellSession = class(TListObject)
 public
  {}
  constructor Create(AShell:TShell;AIdentifier:LongWord);
  destructor Destroy; override;
 private
  {Internal Variables}
  FShell:TShell;
  
  FLock:TCriticalSectionHandle; 
  
  FIdentifier:LongWord;  {Unique identifier for this session}
  FFlags:LongWord;

  FPrompt:String;        {Current prompt for this session}
  
  FData:Pointer;         {Shell private data for this session}
  
  {Internal Methods}
  procedure SetFlags(AFlags:LongWord);
  procedure SetData(AData:Pointer);
  
  function GetPrompt:String;
  procedure SetPrompt(const APrompt:String);
 protected
  {Internal Variables}

  {Internal Methods}
  function AcquireLock:Boolean;
  function ReleaseLock:Boolean;
 public
  {Public Properties}
  property Shell:TShell read FShell;
  
  property Identifier:LongWord read FIdentifier;
  property Flags:LongWord read FFlags write SetFlags;
  
  property Prompt:String read GetPrompt write SetPrompt;
  
  property Data:Pointer read FData write SetData;
  
  {Public Methods}
  
 end;
 
 TShellAlias = class;
 TShellCommand = class(TListObject)
 public
  {}
  constructor Create;
  destructor Destroy; override;
 private
  {Internal Variables}
  FManager:TShellManager;
  
  FLock:TCriticalSectionHandle; 
  
  FAliases:TLinkedList;
  
  FName:String;
  FHash:LongWord;
  FFlags:LongWord;
  
  {Internal Methods}
  function GetName:String;
  procedure SetName(const AName:String);
  procedure SetFlags(AFlags:LongWord);
 protected
  {Internal Variables}

  {Internal Methods}
  function AcquireLock:Boolean;
  function ReleaseLock:Boolean;
 public
  {Public Properties}
  property Manager:TShellManager read FManager;
  
  property Name:String read GetName write SetName;
  property Hash:LongWord read FHash;
  property Flags:LongWord read FFlags write SetFlags;
  
  {Public Methods}
  function DoHelp(AShell:TShell;ASession:TShellSession):Boolean; virtual;
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; virtual;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; virtual;
  function DoDefault(AShell:TShell;ASession:TShellSession;const AName:String;AParameters:TStrings):Boolean; virtual;
  function DoExtended(AShell:TShell;ASession:TShellSession;const AName:String;AParameters:TStrings):Boolean; virtual;
  
  function GetAlias(APrevious:TShellAlias;ALock,AUnlock:Boolean):TShellAlias;
  function FindAlias(const AName:String):TShellAlias;
  
  function RegisterAlias(AAlias:TShellAlias):Boolean;
  function DeregisterAlias(AAlias:TShellAlias):Boolean;
 end;

 TShellAlias = class(TListObject)
 public
  {}
  constructor Create;
  destructor Destroy; override;
 private
  {Internal Variables}
  FLock:TCriticalSectionHandle; 
 
  FName:String;
  FHash:LongWord;
  FFlags:LongWord;
 
  {Internal Methods}
  function GetName:String;
  procedure SetName(const AName:String);
  procedure SetFlags(AFlags:LongWord);
 protected
  {Internal Variables}

  {Internal Methods}
  function AcquireLock:Boolean;
  function ReleaseLock:Boolean;
 public
  {Public Properties}
  property Name:String read GetName write SetName;
  property Hash:LongWord read FHash;
  property Flags:LongWord read FFlags write SetFlags;
  
  {Public Methods}
 
 end;
 
 //TShellHistory = class(TListObject) //To Do
 
 TShellCommandHelp = class(TShellCommand)
 public
  {}
  constructor Create;
  destructor Destroy; override;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;

 TShellCommandInfo = class(TShellCommand)
 public
  {}
  constructor Create;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;
 
 TShellCommandVer = class(TShellCommand)
 public
  {}
  constructor Create;
  destructor Destroy; override;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoHelp(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;
 
 TShellCommandTime = class(TShellCommand)
 public
  {}
  constructor Create;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoHelp(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;
 
 TShellCommandClear = class(TShellCommand)
 public
  {}
  constructor Create;
  destructor Destroy; override;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoHelp(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;
 
 TShellCommandRestart = class(TShellCommand)
 public
  {}
  constructor Create;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoHelp(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;
 
 TShellCommandShutdown = class(TShellCommand)
 public
  {}
  constructor Create;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoHelp(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;
 
 //TShellCommandCPU = class(TShellCommand) //To Do //Similar stuff to the WebStatus page (Utilization, Type, Current etc)
 
 TShellCommandUptime = class(TShellCommand)
 public
  {}
  constructor Create;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoHelp(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;
 
 //TShellCommandWorker = class(TShellCommand) //To Do //Increase/Decrease Workers
 
 TShellCommandThreads = class(TShellCommand)
 public
  {}
  constructor Create;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoHelp(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;
 
 TShellCommandMemory = class(TShellCommand)
 public
  {}
  constructor Create;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoHelp(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;
 
 TShellCommandDevices = class(TShellCommand)
 public
  {}
  constructor Create;
 private
  {Internal Variables}
 
  {Internal Methods}
 
 protected
  {Internal Variables}

  {Internal Methods}
  
 public
  {Public Properties}

  {Public Methods}
  function DoHelp(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoInfo(AShell:TShell;ASession:TShellSession):Boolean; override;
  function DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; override;
 end;
 
{==============================================================================}
{var}
 {Shell specific variables}
 
{==============================================================================}
{Initialization Functions}
procedure ShellInit;

{==============================================================================}
{Shell Functions}
function ShellGetShell(APrevious:TShell;ALock,AUnlock:Boolean):TShell;
function ShellFindShell(const AName:String):TShell;
function ShellRegisterShell(AShell:TShell):Boolean;
function ShellDeregisterShell(AShell:TShell):Boolean;

function ShellGetCommand(APrevious:TShellCommand;ALock,AUnlock:Boolean):TShellCommand;
function ShellFindCommand(const AName:String):TShellCommand;
function ShellRegisterCommand(ACommand:TShellCommand):Boolean;
function ShellDeregisterCommand(ACommand:TShellCommand):Boolean;

{==============================================================================}
{Shell Helper Functions}
procedure ShellLog(Level:LongWord;const AText:String);
procedure ShellLogInfo(const AText:String);
procedure ShellLogError(const AText:String);
procedure ShellLogDebug(const AText:String);

{==============================================================================}
{==============================================================================}

implementation

{==============================================================================}
{==============================================================================}
var
 {Shell specific variables}
 ShellInitialized:Boolean;

 ShellManager:TShellManager;
 
{==============================================================================}
{==============================================================================}
{TShellManager}
constructor TShellManager.Create;
begin
 {}
 inherited Create;
 FLock:=CriticalSectionCreate;

 FShells:=TLinkedList.Create;
 FCommands:=TLinkedList.Create;
end;
 
{==============================================================================}

destructor TShellManager.Destroy; 
begin
 {}
 AcquireLock;
 try
  FShells.Free;
  FCommands.Free;
  inherited Destroy;
 finally
  {ReleaseLock;} {Can destroy Critical Section while holding lock} 
  CriticalSectionDestroy(FLock);
 end;
end;

{==============================================================================}

function TShellManager.AcquireLock:Boolean;
begin
 {}
 Result:=(CriticalSectionLock(FLock) = ERROR_SUCCESS);
end;

{==============================================================================}

function TShellManager.ReleaseLock:Boolean;
begin
 {}
 Result:=(CriticalSectionUnlock(FLock) = ERROR_SUCCESS);
end;

{==============================================================================}

function TShellManager.GetShell(APrevious:TShell;ALock,AUnlock:Boolean):TShell;
var
 Shell:TShell;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  {Check Previous}
  if APrevious = nil then
   begin
    {Get First}
    Shell:=TShell(FShells.First);
    if Shell <> nil then
     begin
      {Lock Shell}
      if ALock then Shell.AcquireLock;
      
      {Return Result}
      Result:=Shell;
     end;
   end
  else
   begin
    {Get Next}
    Shell:=TShell(APrevious.Next);
    if Shell <> nil then
     begin
      {Lock Shell}
      if ALock then Shell.AcquireLock;
      
      {Return Result}
      Result:=Shell;
     end;

    {Unlock Previous}
    if AUnlock then APrevious.ReleaseLock;
   end;   
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShellManager.FindShell(const AName:String):TShell;
var
 Hash:LongWord;
 Shell:TShell;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  if Length(AName) = 0 then Exit;
  
  Hash:=GenerateNameHash(AName,stringHashSize);
  Shell:=TShell(FShells.First);
  while Shell <> nil do
   begin
    if Shell.Hash = Hash then
     begin
      if Uppercase(Shell.Name) = Uppercase(AName) then
       begin
        Result:=Shell;
        Exit;
       end;
     end;

    Shell:=TShell(Shell.Next);   
   end;
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShellManager.RegisterShell(AShell:TShell):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Manager: RegisterShell');
  {$ENDIF}
  
  {Check Shell}
  if AShell = nil then Exit; 
  if Length(AShell.Name) = 0 then Exit;
  
  {Check Name}
  if FindShell(AShell.Name) <> nil then Exit;
 
  {Add Shell}
  Result:=FShells.Add(AShell);
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShellManager.DeregisterShell(AShell:TShell):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Manager: DeregisterShell');
  {$ENDIF}
 
  {Check Shell}
  if AShell = nil then Exit; 
 
  {Check Name}
  if FindShell(AShell.Name) = nil then Exit;
  
  {Remove Shell}
  Result:=FShells.Remove(AShell);
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShellManager.GetCommand(APrevious:TShellCommand;ALock,AUnlock:Boolean):TShellCommand;
var
 Command:TShellCommand;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  {Check Previous}
  if APrevious = nil then
   begin
    {Get First}
    Command:=TShellCommand(FCommands.First);
    if Command <> nil then
     begin
      {Lock Command}
      if ALock then Command.AcquireLock;
      
      {Return Result}
      Result:=Command;
     end;
   end
  else
   begin
    {Get Next}
    Command:=TShellCommand(APrevious.Next);
    if Command <> nil then
     begin
      {Lock Command}
      if ALock then Command.AcquireLock;
      
      {Return Result}
      Result:=Command;
     end;

    {Unlock Previous}
    if AUnlock then APrevious.ReleaseLock;
   end;   
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShellManager.FindCommand(const AName:String):TShellCommand;
var
 Hash:LongWord;
 Command:TShellCommand;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  if Length(AName) = 0 then Exit;
  
  Hash:=GenerateNameHash(AName,stringHashSize);
  Command:=TShellCommand(FCommands.First);
  while Command <> nil do
   begin
    if Command.Hash = Hash then
     begin
      if Uppercase(Command.Name) = Uppercase(AName) then
       begin
        Result:=Command;
        Exit;
       end;
     end;

    Command:=TShellCommand(Command.Next);   
   end;
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShellManager.DefaultCommand:TShellCommand;
var
 Command:TShellCommand;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  Command:=TShellCommand(FCommands.First);
  while Command <> nil do
   begin
    if (Command.Flags and SHELL_COMMAND_FLAG_DEFAULT) <> 0 then
     begin
      Result:=Command;
      Exit;
     end;

    Command:=TShellCommand(Command.Next);   
   end;
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShellManager.RegisterCommand(ACommand:TShellCommand):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Manager: RegisterCommand');
  {$ENDIF}
  
  {Check Command}
  if ACommand = nil then Exit; 
  if Length(ACommand.Name) = 0 then Exit;
  
  {Check Name}
  if FindCommand(ACommand.Name) <> nil then Exit;
 
  {Add Command}
  Result:=FCommands.Add(ACommand);
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShellManager.DeregisterCommand(ACommand:TShellCommand):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Manager: DeregisterCommand');
  {$ENDIF}
 
  {Check Command}
  if ACommand = nil then Exit; 
 
  {Check Name}
  if FindCommand(ACommand.Name) = nil then Exit;
  
  {Remove Command}
  Result:=FCommands.Remove(ACommand);
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}
{==============================================================================}
{TShell}
constructor TShell.Create;
begin
 {}
 inherited Create;
 FManager:=ShellManager;
 FAuthenticator:=nil;
 
 FLock:=CriticalSectionCreate;
 
 FSessions:=TLinkedList.Create;
 FCommands:=TLinkedList.Create;
 
 Banner:=SHELL_DEFAULT_BANNER;
 Prompt:=SHELL_DEFAULT_PROMPT;
 Error:=SHELL_DEFAULT_ERROR;
 
 FName:='';
 FHash:=0;
 FFlags:=SHELL_FLAG_NONE;
end;

{==============================================================================}

destructor TShell.Destroy; 
begin
 {}
 AcquireLock;
 try
  FManager:=nil;
  FAuthenticator:=nil;
  
  FSessions.Free;
  FCommands.Free;
  inherited Destroy;
 finally
  {ReleaseLock;} {Can destroy Critical Section while holding lock}
  CriticalSectionDestroy(FLock);
 end;
end;

{==============================================================================}

procedure TShell.SetAuthenticator(AAuthenticator:TAuthenticator);
begin
 {}
 if not AcquireLock then Exit;

 FAuthenticator:=AAuthenticator;

 ReleaseLock;
end;

{==============================================================================}

function TShell.GetBanner:String;
begin
 {}
 Result:='';
 
 if not AcquireLock then Exit;

 Result:=FBanner;
 UniqueString(Result);

 ReleaseLock;
end;

{==============================================================================}

procedure TShell.SetBanner(const ABanner:String); 
begin
 {}
 if not AcquireLock then Exit;

 FBanner:=ABanner;
 UniqueString(FBanner);
 
 ReleaseLock;
end;

{==============================================================================}

function TShell.GetPrompt:String;
begin
 {}
 Result:='';
 
 if not AcquireLock then Exit;

 Result:=FPrompt;
 UniqueString(Result);

 ReleaseLock;
end;

{==============================================================================}

procedure TShell.SetPrompt(const APrompt:String);
begin
 {}
 if not AcquireLock then Exit;

 FPrompt:=APrompt;
 UniqueString(FPrompt);
 
 ReleaseLock;
end;

{==============================================================================}

function TShell.GetError:String;
begin
 {}
 Result:='';
 
 if not AcquireLock then Exit;

 Result:=FError;
 UniqueString(Result);

 ReleaseLock;
end;

{==============================================================================}

procedure TShell.SetError(const AError:String);
begin
 {}
 if not AcquireLock then Exit;

 FError:=AError;
 UniqueString(FError);
 
 ReleaseLock;
end;

{==============================================================================}
  
function TShell.GetName:String;
begin
 {}
 Result:='';
 
 if not AcquireLock then Exit;

 Result:=FName;
 UniqueString(Result);

 ReleaseLock;
end;

{==============================================================================}

procedure TShell.SetName(const AName:String);
begin
 {}
 if not AcquireLock then Exit;

 FName:=AName;
 UniqueString(FName);
 FHash:=GenerateNameHash(FName,stringHashSize);
 
 ReleaseLock;
end;

{==============================================================================}

procedure TShell.SetFlags(AFlags:LongWord);
begin
 {}
 if not AcquireLock then Exit;

 FFlags:=AFlags;

 ReleaseLock;
end;

{==============================================================================}

function TShell.AcquireLock:Boolean;
begin
 {}
 Result:=(CriticalSectionLock(FLock) = ERROR_SUCCESS);
end;

{==============================================================================}

function TShell.ReleaseLock:Boolean;
begin
 {}
 Result:=(CriticalSectionUnlock(FLock) = ERROR_SUCCESS);
end;

{==============================================================================}
 
function TShell.DoClear(ASession:TShellSession):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;
 
{==============================================================================}
 
function TShell.DoBanner(ASession:TShellSession):Boolean; 
begin
 {Virtual Base}
 Result:=DoOutput(ASession,Banner);
end;

{==============================================================================}

function TShell.DoPrompt(ASession:TShellSession):Boolean; 
begin
 {Virtual Base}
 Result:=False;
 
 {Check Session}
 if ASession = nil then Exit;
 
 Result:=DoOutputEx(ASession,ASession.Prompt,False);
end;

{==============================================================================}

function TShell.DoError(ASession:TShellSession):Boolean; 
begin
 {Virtual Base}
 Result:=DoOutput(ASession,Error);
end;

{==============================================================================}

function TShell.DoInput(ASession:TShellSession;var AInput:String):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;

{==============================================================================}

function TShell.DoOutput(ASession:TShellSession;const AOutput:String):Boolean;
begin
 {Virtual Base}
 Result:=DoOutputEx(ASession,AOutput,True);
end;

{==============================================================================}

function TShell.DoOutputEx(ASession:TShellSession;const AOutput:String;AReturn:Boolean):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;
 
{==============================================================================}
  
function TShell.DoGetSize(ASession:TShellSession;var ARows,ACols:LongWord):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;

{==============================================================================}

function TShell.DoSetSize(ASession:TShellSession;ARows,ACols:LongWord):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;
 
{==============================================================================}

function TShell.DoGetCursor(ASession:TShellSession;var ARow,ACol:LongWord):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;
 
{==============================================================================}

function TShell.DoSetCursor(ASession:TShellSession;ARow,ACol:LongWord):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;
 
{==============================================================================}

function TShell.DoGetColors(ASession:TShellSession;var AForecolor,ABackcolor:LongWord):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;
 
{==============================================================================}

function TShell.DoSetColors(ASession:TShellSession;AForecolor,ABackcolor:LongWord):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;
 
{==============================================================================}

function TShell.DoGetCoordinates(ASession:TShellSession;var ARow,ACol:LongWord):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;
 
{==============================================================================}

function TShell.DoSetCoordinates(ASession:TShellSession;ARow,ACol:LongWord):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;
 
{==============================================================================}

function TShell.GetSession(APrevious:TShellSession;ALock,AUnlock:Boolean):TShellSession;
var
 Session:TShellSession;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  {Check Previous}
  if APrevious = nil then
   begin
    {Get First}
    Session:=TShellSession(FSessions.First);
    if Session <> nil then
     begin
      {Lock Session}
      if ALock then Session.AcquireLock;
      
      {Return Result}
      Result:=Session;
     end;
   end
  else
   begin
    {Get Next}
    Session:=TShellSession(APrevious.Next);
    if Session <> nil then
     begin
      {Lock Session}
      if ALock then Session.AcquireLock;
      
      {Return Result}
      Result:=Session;
     end;

    {Unlock Previous}
    if AUnlock then APrevious.ReleaseLock;
   end;   
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShell.FindSession(AIdentifier:LongWord):TShellSession;
var
 Session:TShellSession;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  Session:=TShellSession(FSessions.First);
  while Session <> nil do
   begin
    if Session.Identifier = AIdentifier then
     begin
      Result:=Session;
      Exit;
     end;

    Session:=TShellSession(Session.Next);
   end;
 finally
  ReleaseLock;
 end; 
end;
 
{==============================================================================}

function TShell.CreateSession(AIdentifier:LongWord):TShellSession;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Shell: CreateSession');
  {$ENDIF}
  
  {Check Identifier}
  if FindSession(AIdentifier) <> nil then Exit;
 
  {Create Session}
  Result:=TShellSession.Create(Self,AIdentifier);
 
  {Add Session}
  if not FSessions.Add(Result) then
   begin
    Result.Free;
    Result:=nil;
   end;
 finally
  ReleaseLock;
 end; 
end;
 
{==============================================================================}

function TShell.DestroySession(ASession:TShellSession):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Shell: DestroySession');
  {$ENDIF}
 
  {Check Session}
  if ASession = nil then Exit; 
 
  {Check Identifier}
  if FindSession(ASession.Identifier) = nil then Exit;
  
  {Remove Session}
  if FSessions.Remove(ASession) then
   begin
    {Destroy Session}
    ASession.Free;
    
    Result:=True;
   end;
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShell.RegisterSession(ASession:TShellSession):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Shell: RegisterSession');
  {$ENDIF}
  
  {Check Session}
  if ASession = nil then Exit; 
 
  {Check Name}
  if FindSession(ASession.Identifier) <> nil then Exit;
 
  {Add Session}
  Result:=FSessions.Add(ASession);
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShell.DeregisterSession(ASession:TShellSession):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Shell: DeregisterSession');
  {$ENDIF}
 
  {Check Session}
  if ASession = nil then Exit; 
 
  {Check Name}
  if FindSession(ASession.Identifier) = nil then Exit;
  
  {Remove Session}
  Result:=FSessions.Remove(ASession);
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShell.GetCommand(APrevious:TShellCommand;ALock,AUnlock:Boolean):TShellCommand;
var
 Command:TShellCommand;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  {Check Previous}
  if APrevious = nil then
   begin
    {Get First}
    Command:=TShellCommand(FCommands.First);
    if Command <> nil then
     begin
      {Lock Command}
      if ALock then Command.AcquireLock;
      
      {Return Result}
      Result:=Command;
     end;
   end
  else
   begin
    {Get Next}
    Command:=TShellCommand(APrevious.Next);
    if Command <> nil then
     begin
      {Lock Command}
      if ALock then Command.AcquireLock;
      
      {Return Result}
      Result:=Command;
     end;

    {Unlock Previous}
    if AUnlock then APrevious.ReleaseLock;
   end;   
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}

function TShell.FindCommand(const AName:String):TShellCommand;
var
 Hash:LongWord;
 Command:TShellCommand;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  if Length(AName) = 0 then Exit;
  
  Hash:=GenerateNameHash(AName,stringHashSize);
  Command:=TShellCommand(FCommands.First);
  while Command <> nil do
   begin
    if Command.Hash = Hash then
     begin
      if Uppercase(Command.Name) = Uppercase(AName) then
       begin
        Result:=Command;
        Exit;
       end;
     end;

    Command:=TShellCommand(Command.Next);   
   end;
 finally
  ReleaseLock;
 end; 
end;
 
{==============================================================================}

function TShell.DefaultCommand:TShellCommand;
var
 Command:TShellCommand;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  Command:=TShellCommand(FCommands.First);
  while Command <> nil do
   begin
    if (Command.Flags and SHELL_COMMAND_FLAG_DEFAULT) <> 0 then
     begin
      Result:=Command;
      Exit;
     end;

    Command:=TShellCommand(Command.Next);   
   end;
 finally
  ReleaseLock;
 end; 
end;
 
{==============================================================================}

function TShell.RegisterCommand(ACommand:TShellCommand):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Shell: RegisterCommand');
  {$ENDIF}
  
  {Check Command}
  if ACommand = nil then Exit; 
  if Length(ACommand.Name) = 0 then Exit;
  
  {Check Name}
  if FindCommand(ACommand.Name) <> nil then Exit;
 
  {Add Command}
  Result:=FCommands.Add(ACommand);
 finally
  ReleaseLock;
 end; 
end;
 
{==============================================================================}

function TShell.DeregisterCommand(ACommand:TShellCommand):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Shell: DeregisterCommand');
  {$ENDIF}
 
  {Check Command}
  if ACommand = nil then Exit; 
 
  {Check Name}
  if FindCommand(ACommand.Name) = nil then Exit;
  
  {Remove Command}
  Result:=FCommands.Remove(ACommand);
 finally
  ReleaseLock;
 end; 
end;
 
 {==============================================================================}

function TShell.MatchCommand(const ACommand:String;var AContinue:Boolean):TShellCommand; 
{Check the supplied command against registered commands, if matched return command as result}
{Command: The command to match}
{Continue: Returns true if more than one command matches and matching should be retried}
begin
 {Virtual Base}
 Result:=nil;
 
 //To Do
end;

{==============================================================================}

function TShell.ProcessCommand(ASession:TShellSession;const ACommand:String):Boolean; 
{Process the supplied command against the registered commands}
{Command: The command to process}
var
 Name:String;
 Parameters:TStrings;
 Current:TShellCommand;
 Command:TShellCommand;
begin
 {Virtual Base}
 Result:=False;
 
 {Check Session}
 if ASession = nil then Exit;
 
 {Parse Command}
 Name:='';
 Parameters:=nil;
 if CommandParse(ACommand,Name,Parameters) then
  begin
   Command:=nil;
   
   {Check Global Commands}
   Command:=Manager.FindCommand(Name);
   if Command = nil then
    begin
     {Check Local Commands}
     Command:=FindCommand(Name);
     if Command = nil then 
      begin
       {Check Global Aliases}
       Current:=Manager.GetCommand(nil,True,False);
       while Current <> nil do
        begin
         {Check Aliases}
         if Current.FindAlias(Name) <> nil then
          begin
           {Get Command}
           Command:=Current;
           
           {Unlock Current}
           Current.ReleaseLock;
           Break;
          end;
          
         {Get Next}
         Current:=Manager.GetCommand(Current,True,True);
        end;
      end;
     if Command = nil then
      begin
       {Check Local Aliases}
       Current:=GetCommand(nil,True,False);
       while Current <> nil do
        begin
         {Check Aliases}
         if Current.FindAlias(Name) <> nil then
          begin
           {Get Command}
           Command:=Current;
           
           {Unlock Current}
           Current.ReleaseLock;
           Break;
          end;
        
         {Get Next}
         Current:=GetCommand(Current,True,True);
        end;
      end;
    end;
   
   {Check Command}   
   if Command <> nil then
    begin
     {Check Flags}
     if (Command.Flags and SHELL_COMMAND_FLAG_EXTENDED) = 0 then
      begin
       {Process Command}
       Result:=Command.DoCommand(Self,ASession,Parameters);
      end
     else
      begin
       {Process Extended}
       Result:=Command.DoExtended(Self,ASession,Name,Parameters);
      end;      
    end
   else
    begin
     {Check Global Default}
     Command:=Manager.DefaultCommand;
     if Command = nil then
      begin
       {Check Local Default}
       Command:=DefaultCommand;
      end;
      
     {Check Command}
     if Command <> nil then
      begin     
       {Process Default}
       Result:=Command.DoDefault(Self,ASession,Name,Parameters);
      end;
      
     {Send Error}
     if not(Result) then DoError(ASession);
    end;    
  end;  
end;
 
{==============================================================================}
 
function TShell.CommandName(const ACommand:String):String;
{Extract the command name from the command line}
var
 PosIdx:Integer;
 Command:String;
begin
 {}
 Result:='';
 
 {Trim Command}
 Command:=Trim(ACommand);
 if Length(Command) > 0 then
  begin
   {Get First Space}
   PosIdx:=Pos(' ',Command);
   if PosIdx <> 0 then
    begin
     {Copy Command}
     Result:=Copy(Command,1,PosIdx - 1);
    end
   else
    begin
     {Return Command}
     Result:=Command;
    end;
  end;
end;
 
{==============================================================================}

function TShell.CommandSplit(const ACommand:String):TStrings;
{Split the command line into individual components}
{Note: Allows for quoted parameters which include spaces}
var
 Count:Integer;
 Quotes:Boolean;
 Command:String;
 Parameter:String;
begin
 {}
 Result:=TStringList.Create;

 {Trim Command}
 Command:=Trim(ACommand);
 while Length(Command) > 0 do
  begin
   Quotes:=False;
   Parameter:='';
   for Count:=1 to Length(Command) do
    begin
     {Check Space}
     if Command[Count] = ' ' then
      begin
       {Check Quotes}
       if Quotes then
        begin
         {Add Buffer}
         Parameter:=Parameter + Command[Count];
        end
       else
        begin
         {Delete Buffer}
         Delete(Command,1,Count);
         
         {Add Result}
         Result.Add(Parameter);
         
         Break;
        end;
      end
     {Check Quote} 
     else if Command[Count] = '"' then
      begin
       {Toggle Quotes}
       Quotes:=not(Quotes);
      end
     else
      begin
       {Add Buffer}
       Parameter:=Parameter + Command[Count];
      end;
      
     {Check End}
     if Count = Length(Command) then
      begin
       {Delete Buffer}
       Delete(Command,1,Count);
       
       {Add Result}
       Result.Add(Parameter);
       
       Break;
      end;
    end;
  end;
end;

{==============================================================================}

function TShell.CommandParse(const ACommand:String;var AName:String;var AParameters:TStrings):Boolean;
{Parse the command line into the command name and parameters}
begin
 {}
 Result:=False;
 
 {Check Parameters}
 if AParameters <> nil then Exit;
 
 {Get Name}
 AName:=CommandName(ACommand);
 if Length(AName) = 0 then Exit;
 
 {Get Parameters}
 AParameters:=CommandSplit(ACommand);
 if AParameters = nil then Exit;
 if AParameters.Count = 0 then Exit;
 
 {Delete Name}
 AParameters.Delete(0);
 
 {Return Result}
 Result:=True;
end;

{==============================================================================}

function TShell.CommandIndex(AIndex:Integer;const ACommand:String):String;
{Return the command line parameter specified by Index (0 is the command name, 1 is the first parameter etc)}
var
 Parameters:TStrings;
begin
 {}
 Result:='';
 
 {Check Index}
 if AIndex < 0 then Exit;
 
 {Split Command}
 Parameters:=CommandSplit(ACommand);
 try
  {Check Index}
  if AIndex < Parameters.Count then
   begin
    {Get Parameter}
    Result:=Parameters.Strings[AIndex];
   end;
 finally
  Parameters.Free;
 end;
end;

{==============================================================================}

function TShell.ParameterIndex(AIndex:Integer;AParameters:TStrings):String;
{Return the command line parameter specified by Index (0 is the first parameter, 1 is the second etc)}
begin
 {}
 Result:='';

 {Check Index}
 if AIndex < 0 then Exit;
 
 {Check Parameters}
 if AParameters = nil then Exit;
 
 {Check Index}
 if AIndex < AParameters.Count then
  begin
   {Get Parameter}
   Result:=AParameters.Strings[AIndex];
  end;
end;

{==============================================================================}

function TShell.ParameterValue(const AParameter:String;AParameters:TStrings):String;
begin
 {}
 Result:=ParameterValueEx(AParameter,AParameters,False,True);
end;

{==============================================================================}

function TShell.ParameterExists(const AParameter:String;AParameters:TStrings):Boolean;
begin
 {}
 Result:=ParameterExistsEx(AParameter,AParameters,False,True);
end;

{==============================================================================}

function TShell.ParameterValueEx(const AParameter:String;AParameters:TStrings;APlus,AMinus:Boolean):String;
{Return the value of the command line parameter specified by Parameter}
{Note: Allows for parameters prefixed with Slash (/), Plus (+) or Minus (-)}
var
 Count:Integer;
 PosIdx:Integer;
 Value:String;
 Current:String;
 Parameter:String;
begin
 {}
 Result:='';
 
 {Check Exists}
 if ParameterExistsEx(AParameter,AParameters,APlus,AMinus) then
  begin
   {Format Parameter}
   Parameter:=Uppercase(Trim(AParameter));
   for Count:=0 to AParameters.Count - 1 do
    begin
     {Get Parameter}
     Current:=Trim(AParameters.Strings[Count]);
     
     {Remove Slash}
     Current:=StripLeadingChar(Current,'/');
     
     {Remove Plus}
     if APlus then Current:=StripLeadingChar(Current,'+');
     
     {Remove Minus}
     if AMinus then Current:=StripLeadingChar(Current,'-');
     
     {Get First Equals}
     PosIdx:=Pos('=',Current);
     if PosIdx <> 0 then
      begin
       {Get Value}
       Value:=Copy(Current,PosIdx + 1,Length(Current));
       
       {Remove Value}
       Delete(Current,PosIdx,Length(Current));
       
       {Check Parameter} 
       if Parameter = Uppercase(Current) then
        begin
         Result:=Value;
         Exit;
        end;
      end;
    end;
  end;
end;

{==============================================================================}

function TShell.ParameterExistsEx(const AParameter:String;AParameters:TStrings;APlus,AMinus:Boolean):Boolean;
{Check for the existence of the command line parameter specified by Parameter}
{Note: Allows for parameters prefixed with Slash (/), Plus (+) or Minus (-)}
var
 Count:Integer;
 PosIdx:Integer;
 Current:String;
 Parameter:String;
begin
 {}
 Result:=False;
 
 {Check Parameters}
 if AParameters = nil then Exit;
 
 {Check Parameter}
 if Trim(AParameter) = '' then Exit;

 {Format Parameter}
 Parameter:=Uppercase(Trim(AParameter));
 for Count:=0 to AParameters.Count - 1 do
  begin
   {Get Parameter}
   Current:=Trim(AParameters.Strings[Count]);
   
   {Remove Slash}
   Current:=StripLeadingChar(Current,'/');
   
   {Remove Plus}
   if APlus then Current:=StripLeadingChar(Current,'+');
   
   {Remove Minus}
   if AMinus then Current:=StripLeadingChar(Current,'-');
   
   {Get First Equals}
   PosIdx:=Pos('=',Current);
   if PosIdx <> 0 then
    begin
     {Remove Value}
     Delete(Current,PosIdx,Length(Current));
    end;
    
   {Check Parameter} 
   if Parameter = Uppercase(Current) then
    begin
     Result:=True;
     Exit;
    end;
  end;
end;
 
{==============================================================================}
 
function TShell.AddOutput(var AOutput:String;ACol:LongWord;const AValue:String):Boolean;
begin
 {}
 Result:=False;
 
 if Length(AOutput) = 0 then
  begin
   {Add Columns}
   if ACol > 0 then
    begin
     AOutput:=AOutput + StringOfChar(' ',ACol);   
    end;
   
   {Add Value}
   AOutput:=AOutput + AValue;   
  end
 else
  begin
   {Add Columns}
   if ACol > 0 then
    begin
     if Length(AOutput) < ACol then
      begin
       AOutput:=AOutput + StringOfChar(' ',ACol - Length(AOutput));   
      end
     else 
      begin
       AOutput:=Copy(AOutput,1,ACol);
      end; 
    end;
   
   {Add Value}
   AOutput:=AOutput + AValue;   
  end;  
 
 Result:=True;
end;
 
{==============================================================================}
{==============================================================================}
{TShellSession}
constructor TShellSession.Create(AShell:TShell;AIdentifier:LongWord);
begin
 {}
 inherited Create;
 FShell:=AShell;
 
 FLock:=CriticalSectionCreate;
 
 FIdentifier:=AIdentifier;
 FFlags:=SHELL_SESSION_FLAG_NONE;
 
 Prompt:=SHELL_DEFAULT_BANNER;
 if FShell <> nil then Prompt:=FShell.Prompt;
end;

{==============================================================================}

destructor TShellSession.Destroy; 
begin
 {}
 AcquireLock;
 try
  FShell:=nil;
  inherited Destroy;
 finally
  {ReleaseLock;} {Can destroy Critical Section while holding lock}
  CriticalSectionDestroy(FLock);
 end;
end;
 
{==============================================================================}

procedure TShellSession.SetFlags(AFlags:LongWord);
begin
 {}
 if not AcquireLock then Exit;

 FFlags:=AFlags;

 ReleaseLock;
end;

{==============================================================================}

procedure TShellSession.SetData(AData:Pointer);
begin
 {}
 if not AcquireLock then Exit;

 FData:=AData;

 ReleaseLock;
end;

{==============================================================================}

function TShellSession.GetPrompt:String;
begin
 {}
 Result:='';
 
 if not AcquireLock then Exit;

 Result:=FPrompt;
 UniqueString(Result);

 ReleaseLock;
end;

{==============================================================================}

procedure TShellSession.SetPrompt(const APrompt:String);
begin
 {}
 if not AcquireLock then Exit;

 FPrompt:=APrompt;
 UniqueString(FPrompt);
 
 ReleaseLock;
end;

{==============================================================================}
 
function TShellSession.AcquireLock:Boolean;
begin
 {}
 Result:=(CriticalSectionLock(FLock) = ERROR_SUCCESS);
end;

{==============================================================================}

function TShellSession.ReleaseLock:Boolean;
begin
 {}
 Result:=(CriticalSectionUnlock(FLock) = ERROR_SUCCESS);
end;
 
{==============================================================================}
{==============================================================================}
{TShellCommand}
constructor TShellCommand.Create;
begin
 {}
 inherited Create;
 FManager:=ShellManager;
 
 FLock:=CriticalSectionCreate;
 
 FAliases:=TLinkedList.Create;
 
 FName:='';
 FHash:=0;
 FFlags:=SHELL_COMMAND_FLAG_NONE;
end;

{==============================================================================}

destructor TShellCommand.Destroy; 
begin
 {}
 AcquireLock;
 try
  FManager:=nil;
  
  FAliases.Free;
  inherited Destroy;
 finally
  {ReleaseLock;} {Can destroy Critical Section while holding lock} 
  CriticalSectionDestroy(FLock);
 end;
end;

{==============================================================================}
  
function TShellCommand.GetName:String;
begin
 {}
 Result:='';
 
 if not AcquireLock then Exit;

 Result:=FName;
 UniqueString(Result);

 ReleaseLock;
end;

{==============================================================================}

procedure TShellCommand.SetName(const AName:String);
begin
 {}
 if not AcquireLock then Exit;

 FName:=AName;
 UniqueString(FName);
 FHash:=GenerateNameHash(FName,stringHashSize);
 
 ReleaseLock;
end;

{==============================================================================}

procedure TShellCommand.SetFlags(AFlags:LongWord);
begin
 {}
 if not AcquireLock then Exit;

 FFlags:=AFlags;

 ReleaseLock;
end;

{==============================================================================}

function TShellCommand.AcquireLock:Boolean;
begin
 {}
 Result:=(CriticalSectionLock(FLock) = ERROR_SUCCESS);
end;

{==============================================================================}

function TShellCommand.ReleaseLock:Boolean;
begin
 {}
 Result:=(CriticalSectionUnlock(FLock) = ERROR_SUCCESS);
end;
 
{==============================================================================}
 
function TShellCommand.DoHelp(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;

{==============================================================================}

function TShellCommand.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;

{==============================================================================}

function TShellCommand.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;

{==============================================================================}
 
function TShellCommand.DoDefault(AShell:TShell;ASession:TShellSession;const AName:String;AParameters:TStrings):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;

{==============================================================================}

function TShellCommand.DoExtended(AShell:TShell;ASession:TShellSession;const AName:String;AParameters:TStrings):Boolean; 
begin
 {Virtual Base}
 Result:=False;
end;

{==============================================================================}

function TShellCommand.GetAlias(APrevious:TShellAlias;ALock,AUnlock:Boolean):TShellAlias;
var
 Alias:TShellAlias;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  {Check Previous}
  if APrevious = nil then
   begin
    {Get First}
    Alias:=TShellAlias(FAliases.First);
    if Alias <> nil then
     begin
      {Lock Alias}
      if ALock then Alias.AcquireLock;
      
      {Return Result}
      Result:=Alias;
     end;
   end
  else
   begin
    {Get Next}
    Alias:=TShellAlias(APrevious.Next);
    if Alias <> nil then
     begin
      {Lock Alias}
      if ALock then Alias.AcquireLock;
      
      {Return Result}
      Result:=Alias;
     end;

    {Unlock Previous}
    if AUnlock then APrevious.ReleaseLock;
   end;   
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}
 
function TShellCommand.FindAlias(const AName:String):TShellAlias;
var
 Hash:LongWord;
 Alias:TShellAlias;
begin
 {}
 Result:=nil;
 
 if not AcquireLock then Exit;
 try
  if Length(AName) = 0 then Exit;
  
  Hash:=GenerateNameHash(AName,stringHashSize);
  Alias:=TShellAlias(FAliases.First);
  while Alias <> nil do
   begin
    if Alias.Hash = Hash then
     begin
      if Uppercase(Alias.Name) = Uppercase(AName) then
       begin
        Result:=Alias;
        Exit;
       end;
     end;

    Alias:=TShellAlias(Alias.Next);   
   end;
 finally
  ReleaseLock;
 end; 
end;
 
{==============================================================================}
 
function TShellCommand.RegisterAlias(AAlias:TShellAlias):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Command: RegisterAlias');
  {$ENDIF}
  
  {Check Alias}
  if AAlias = nil then Exit; 
  if Length(AAlias.Name) = 0 then Exit;
  
  {Check Name}
  if FindAlias(AAlias.Name) <> nil then Exit;
 
  {Add Alias}
  Result:=FAliases.Add(AAlias);
 finally
  ReleaseLock;
 end; 
end;

{==============================================================================}
 
function TShellCommand.DeregisterAlias(AAlias:TShellAlias):Boolean;
begin
 {}
 Result:=False;
 
 if not AcquireLock then Exit;
 try
  {$IFDEF SHELL_DEBUG}
  if SHELL_LOG_ENABLED then ShellLogDebug('Command: DeregisterAlias');
  {$ENDIF}
 
  {Check Alias}
  if AAlias = nil then Exit; 
 
  {Check Name}
  if FindAlias(AAlias.Name) = nil then Exit;
  
  {Remove Alias}
  Result:=FAliases.Remove(AAlias);
 finally
  ReleaseLock;
 end; 
end;
 
{==============================================================================}
{==============================================================================}
{TShellAlias}
constructor TShellAlias.Create;
begin
 {}
 inherited Create;
 FLock:=CriticalSectionCreate;
 
 FName:='';
 FHash:=0;
 FFlags:=SHELL_ALIAS_FLAG_NONE;
end;

{==============================================================================}

destructor TShellAlias.Destroy; 
begin
 {}
 AcquireLock;
 try
  inherited Destroy;
 finally
  {ReleaseLock;} {Can destroy Critical Section while holding lock} 
  CriticalSectionDestroy(FLock);
 end;
end;

{==============================================================================}

function TShellAlias.GetName:String;
begin
 {}
 Result:='';
 
 if not AcquireLock then Exit;

 Result:=FName;
 UniqueString(Result);

 ReleaseLock;
end;

{==============================================================================}

procedure TShellAlias.SetName(const AName:String);
begin
 {}
 if not AcquireLock then Exit;

 FName:=AName;
 UniqueString(FName);
 FHash:=GenerateNameHash(FName,stringHashSize);
 
 ReleaseLock;
end;

{==============================================================================}

procedure TShellAlias.SetFlags(AFlags:LongWord);
begin
 {}
 if not AcquireLock then Exit;

 FFlags:=AFlags;

 ReleaseLock;
end;

{==============================================================================}

function TShellAlias.AcquireLock:Boolean;
begin
 {}
 Result:=(CriticalSectionLock(FLock) = ERROR_SUCCESS);
end;

{==============================================================================}

function TShellAlias.ReleaseLock:Boolean;
begin
 {}
 Result:=(CriticalSectionUnlock(FLock) = ERROR_SUCCESS);
end;

{==============================================================================}
{==============================================================================}
{TShellCommandHelp}
constructor TShellCommandHelp.Create;
var
 Alias:TShellAlias;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_HELP;
 Flags:=SHELL_COMMAND_FLAG_INFO;
 
 {Create Alias}
 Alias:=TShellAlias.Create;
 Alias.Name:=SHELL_ALIAS_HELP;
 
 {Register Alias}
 if not RegisterAlias(Alias) then
  begin
   {Destroy Alias}
   Alias.Free;
  end;
end;
 
{==============================================================================}
 
destructor TShellCommandHelp.Destroy; 
var
 Alias:TShellAlias;
begin
 {}
 {Get Alias}
 Alias:=FindAlias(SHELL_ALIAS_HELP);
 
 {Check Alias}
 if Alias <> nil then
  begin
   {Degister Alias}
   DeregisterAlias(Alias);
   
   {Destroy Alias}
   Alias.Free;
  end;
  
 inherited Destroy;
end;
 
{==============================================================================}

function TShellCommandHelp.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'Show help for a specific command (HELP with no parameters lists all commands)');
end;

{==============================================================================}

function TShellCommandHelp.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean;
var
 Parameter:String;
 Current:TShellCommand;
 Command:TShellCommand;
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;

 {Check Parameters}
 if AParameters = nil then Exit;
 
 {Get Parameter}
 Parameter:=AShell.ParameterIndex(0,AParameters);
 if Length(Parameter) > 0 then
  begin
   {Show Help for Command}
   {Check Global Commands}
   Command:=Manager.FindCommand(Parameter);
   if Command = nil then
    begin
     {Check Local Commands}
     Command:=AShell.FindCommand(Parameter);
     if Command = nil then 
      begin
       {Check Global Aliases}
       Current:=Manager.GetCommand(nil,True,False);
       while Current <> nil do
        begin
         {Check Aliases}
         if Current.FindAlias(Parameter) <> nil then
          begin
           {Get Command}
           Command:=Current;
           
           {Unlock Current}
           Current.ReleaseLock;
           Break;
          end;
          
         {Get Next}
         Current:=Manager.GetCommand(Current,True,True);
        end;
      end;
     if Command = nil then
      begin
       {Check Local Aliases}
       Current:=AShell.GetCommand(nil,True,False);
       while Current <> nil do
        begin
         {Check Aliases}
         if Current.FindAlias(Parameter) <> nil then
          begin
           {Get Command}
           Command:=Current;
           
           {Unlock Current}
           Current.ReleaseLock;
           Break;
          end;
        
         {Get Next}
         Current:=AShell.GetCommand(Current,True,True);
        end;
      end; 
    end; 
   
   {Check Command}
   if Command <> nil then
    begin
     {Check Flags}
     if (Command.Flags and SHELL_COMMAND_FLAG_HELP) <> 0 then
      begin
       {Show Header}
       if not AShell.DoOutput(ASession,Command.Name + ' command help') then Exit;
       if not AShell.DoOutput(ASession,'') then Exit;
       
       {Show Help}
       Result:=Command.DoHelp(AShell,ASession);
      end
     else
      begin
       {Show Error}
       AShell.DoOutput(ASession,'No help available for command "' + Parameter + '"');
      end;
    end
   else
    begin
     {Show Error}
     AShell.DoOutput(ASession,Name + ' - Command "' + Parameter + '" not found');
    end;    
  end
 else
  begin
   {Show List of All Commands}
   if not AShell.DoOutput(ASession,'Available commands:') then Exit;
   
   {Global Commands}
   Command:=Manager.GetCommand(nil,True,False);
   while Command <> nil do
    begin
     {Show Name}
     AShell.DoOutput(ASession,' ' + Command.Name);
     
     {Get Next}
     Command:=Manager.GetCommand(Command,True,True);
    end;
   
   {Local Commands}
   Command:=AShell.GetCommand(nil,True,False);
   while Command <> nil do
    begin
     {Show Name}
     AShell.DoOutput(ASession,' ' + Command.Name);
     
     {Get Next}
     Command:=AShell.GetCommand(Command,True,True);
    end;
   
   {Return Result}
   Result:=True;
  end;  
end;

{==============================================================================}
{==============================================================================}
{TShellCommandInfo}
constructor TShellCommandInfo.Create;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_INFO;
 Flags:=SHELL_COMMAND_FLAG_INFO;
end;
 
{==============================================================================}

function TShellCommandInfo.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'Show brief info for a command (INFO with no parameters shows info for all commands)');
end;

{==============================================================================}

function TShellCommandInfo.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean;
var
 Parameter:String;
 Current:TShellCommand;
 Command:TShellCommand;
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;

 {Check Parameters}
 if AParameters = nil then Exit;
 
 {Get Parameter}
 Parameter:=AShell.ParameterIndex(0,AParameters);
 if Length(Parameter) > 0 then
  begin
   {Show Info for Command}
   {Check Global Commands}
   Command:=Manager.FindCommand(Parameter);
   if Command = nil then
    begin
     {Check Local Commands}
     Command:=AShell.FindCommand(Parameter);
     if Command = nil then 
      begin
       {Check Global Aliases}
       Current:=Manager.GetCommand(nil,True,False);
       while Current <> nil do
        begin
         {Check Aliases}
         if Current.FindAlias(Parameter) <> nil then
          begin
           {Get Command}
           Command:=Current;
           
           {Unlock Current}
           Current.ReleaseLock;
           Break;
          end;
          
         {Get Next}
         Current:=Manager.GetCommand(Current,True,True);
        end;
      end;
     if Command = nil then
      begin
       {Check Local Aliases}
       Current:=AShell.GetCommand(nil,True,False);
       while Current <> nil do
        begin
         {Check Aliases}
         if Current.FindAlias(Parameter) <> nil then
          begin
           {Get Command}
           Command:=Current;
           
           {Unlock Current}
           Current.ReleaseLock;
           Break;
          end;
        
         {Get Next}
         Current:=AShell.GetCommand(Current,True,True);
        end;
      end; 
    end; 
   
   {Check Command}
   if Command <> nil then
    begin
     {Show Name}
     if not AShell.DoOutputEx(ASession,Command.Name + ' - ',False) then Exit;
     
     {Check Flags}
     if (Command.Flags and SHELL_COMMAND_FLAG_INFO) <> 0 then
      begin
       {Show Info}
       Result:=Command.DoInfo(AShell,ASession);
      end
     else
      begin
       {Show Error}
       Result:=AShell.DoOutput(ASession,'No info available');
      end;
    end
   else
    begin
     {Show Error}
     AShell.DoOutput(ASession,Name + ' - Command "' + Parameter + '" not found');
    end;    
  end
 else
  begin
   {Show Info for All Commands}
   if not AShell.DoOutput(ASession,'Available commands:') then Exit;
   
   {Global Commands}
   Command:=Manager.GetCommand(nil,True,False);
   while Command <> nil do
    begin
     {Show Name}
     AShell.DoOutputEx(ASession,' ' + Command.Name + ' - ',False);
     
     {Check Flags}
     if (Command.Flags and SHELL_COMMAND_FLAG_INFO) <> 0 then
      begin
       {Show Info}
       Command.DoInfo(AShell,ASession);
      end
     else
      begin
       {Show Error}
       AShell.DoOutput(ASession,'No info available');
      end;      
     
     {Get Next}
     Command:=Manager.GetCommand(Command,True,True);
    end;
   
   {Local Commands}
   Command:=AShell.GetCommand(nil,True,False);
   while Command <> nil do
    begin
     {Show Name}
     AShell.DoOutputEx(ASession,' ' + Command.Name + ' - ',False);
     
     {Check Flags}
     if (Command.Flags and SHELL_COMMAND_FLAG_INFO) <> 0 then
      begin
       {Show Info}
       Command.DoInfo(AShell,ASession);
      end
     else
      begin
       {Show Error}
       AShell.DoOutput(ASession,'No info available');
      end;      
     
     {Get Next}
     Command:=AShell.GetCommand(Command,True,True);
    end;
   
   {Return Result}
   Result:=True;
  end;  
end;
 
{==============================================================================}
{==============================================================================}
{TShellCommandVer}
constructor TShellCommandVer.Create;
var
 Alias:TShellAlias;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_VER;
 Flags:=SHELL_COMMAND_FLAG_INFO or SHELL_COMMAND_FLAG_HELP;
 
 {Create Alias}
 Alias:=TShellAlias.Create;
 Alias.Name:=SHELL_ALIAS_VERSION;
 
 {Register Alias}
 if not RegisterAlias(Alias) then
  begin
   {Destroy Alias}
   Alias.Free;
  end;
end;

{==============================================================================}
 
destructor TShellCommandVer.Destroy; 
var
 Alias:TShellAlias;
begin
 {}
 {Get Alias}
 Alias:=FindAlias(SHELL_ALIAS_VERSION);
 
 {Check Alias}
 if Alias <> nil then
  begin
   {Degister Alias}
   DeregisterAlias(Alias);
   
   {Destroy Alias}
   Alias.Free;
  end;
  
 inherited Destroy;
end;

{==============================================================================}

function TShellCommandVer.DoHelp(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Help}
 Result:=AShell.DoOutput(ASession,'Show version information for Ultibo Core');
end;

{==============================================================================}

function TShellCommandVer.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'Show version information');
end;

{==============================================================================}

function TShellCommandVer.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Show Version}
 Result:=AShell.DoOutput(ASession,SHELL_DEFAULT_BANNER);
end;

{==============================================================================}
{==============================================================================}
{TShellCommandTime}
constructor TShellCommandTime.Create;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_TIME;
 Flags:=SHELL_COMMAND_FLAG_INFO or SHELL_COMMAND_FLAG_HELP;
end;

{==============================================================================}

function TShellCommandTime.DoHelp(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Help}
 Result:=AShell.DoOutput(ASession,'Display or set the current system time');
end;

{==============================================================================}

function TShellCommandTime.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'Display or set the current system time');
end;

{==============================================================================}

function TShellCommandTime.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean;
var 
 Parameter:String;
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;

 {Check Parameters}
 if AParameters = nil then Exit;
 
 {Get Parameter}
 Parameter:=AShell.ParameterIndex(0,AParameters);
 
 {Check Parameter}
 if (Length(Parameter) = 0) or (Uppercase(Parameter) = 'GET') then
  begin
   {Show Local Time}
   if not AShell.DoOutput(ASession,'Local time: ' + DateTimeToStr(Now)) then Exit;
   
   {Show UTC Time}
   if not AShell.DoOutput(ASession,'UTC time: ' + DateTimeToStr(SystemFileTimeToDateTime(GetCurrentTime))) then Exit; {No Conversion}
   
   {Show Timezone}
   Result:= AShell.DoOutput(ASession,'Timezone: ' + GetCurrentTimezone);
  end
 else if Uppercase(Parameter) = 'SET' then
  begin
   //To Do 
   Result:= AShell.DoOutput(ASession,'Sorry, not implemented yet');
  end
 else
  begin
   {Show Error}
   Result:=AShell.DoError(ASession);
  end;  
end;

{==============================================================================}
{==============================================================================}
{TShellCommandClear}
constructor TShellCommandClear.Create;
var
 Alias:TShellAlias;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_CLS;
 Flags:=SHELL_COMMAND_FLAG_INFO or SHELL_COMMAND_FLAG_HELP;
 
 {Create Alias}
 Alias:=TShellAlias.Create;
 Alias.Name:=SHELL_ALIAS_CLEAR;
 
 {Register Alias}
 if not RegisterAlias(Alias) then
  begin
   {Destroy Alias}
   Alias.Free;
  end;
end;
 
{==============================================================================}
 
destructor TShellCommandClear.Destroy; 
var
 Alias:TShellAlias;
begin
 {}
 {Get Alias}
 Alias:=FindAlias(SHELL_ALIAS_CLEAR);
 
 {Check Alias}
 if Alias <> nil then
  begin
   {Degister Alias}
   DeregisterAlias(Alias);
   
   {Destroy Alias}
   Alias.Free;
  end;
  
 inherited Destroy;
end;

{==============================================================================}

function TShellCommandClear.DoHelp(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Help}
 Result:=AShell.DoOutput(ASession,'Clear the screen if supported by the current shell');
end;

{==============================================================================}

function TShellCommandClear.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'Clear the screen');
end;

{==============================================================================}

function TShellCommandClear.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Clear Screen}
 Result:=AShell.DoClear(ASession);
end;

{==============================================================================}
{==============================================================================}
{TShellCommandRestart}
constructor TShellCommandRestart.Create;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_RESTART;
 Flags:=SHELL_COMMAND_FLAG_INFO or SHELL_COMMAND_FLAG_HELP;
end;
 
{==============================================================================}

function TShellCommandRestart.DoHelp(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Help}
 if not AShell.DoOutput(ASession,'Restart the computer immediately or after a specified number of milliseconds') then Exit;
 if not AShell.DoOutput(ASession,'') then Exit;
 if not AShell.DoOutput(ASession,' ' + Name + ' <Milliseconds>') then Exit;
 if not AShell.DoOutput(ASession,'') then Exit;
 if not AShell.DoOutput(ASession,' Examples: RESTART      (Restart immediately)') then Exit;
 if not AShell.DoOutput(ASession,'           RESTART 5000 (Restart in 5000 milliseconds or 5 seconds)') then Exit;
 
 Result:=True;
end;

{==============================================================================}

function TShellCommandRestart.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'Restart the computer');
end;

{==============================================================================}

function TShellCommandRestart.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; 
var
 Delay:LongWord;
 Status:LongWord;
 Parameter:String;
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Check Parameters}
 if AParameters = nil then Exit;
 
 {Get Parameter}
 Parameter:=AShell.ParameterIndex(0,AParameters);
 
 {Get Delay}
 Delay:=StrToIntDef(Parameter,1000); {Default to 1 second}
 
 {Restart}
 Status:=SystemRestart(Delay);
 if Status = ERROR_SUCCESS then
  begin
   {Show Success}
   Result:=AShell.DoOutput(ASession,'Restarting in ' + IntToStr(Delay) + ' milliseconds');
  end
 else
  begin
   {Show Failure}
   Result:=AShell.DoOutput(ASession,'Restart request failed (Error=' + ErrorToString(Status) + ')');
  end;  
end;

{==============================================================================}
{==============================================================================}
{TShellCommandShutdown}
constructor TShellCommandShutdown.Create;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_SHUTDOWN;
 Flags:=SHELL_COMMAND_FLAG_INFO or SHELL_COMMAND_FLAG_HELP;
end;
 
{==============================================================================}

function TShellCommandShutdown.DoHelp(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Help}
 if not AShell.DoOutput(ASession,'Shutdown the computer immediately or after a specified number of milliseconds') then Exit;
 if not AShell.DoOutput(ASession,'') then Exit;
 if not AShell.DoOutput(ASession,' ' + Name + ' <Milliseconds>') then Exit;
 if not AShell.DoOutput(ASession,'') then Exit;
 if not AShell.DoOutput(ASession,' Examples: SHUTDOWN      (Shutdown immediately)') then Exit;
 if not AShell.DoOutput(ASession,'           SHUTDOWN 5000 (Shutdown in 5000 milliseconds or 5 seconds)') then Exit;
 
 Result:=True;
end;

{==============================================================================}

function TShellCommandShutdown.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'Shutdown the computer');
end;

{==============================================================================}

function TShellCommandShutdown.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; 
var
 Delay:LongWord;
 Status:LongWord;
 Parameter:String;
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Check Parameters}
 if AParameters = nil then Exit;
 
 {Get Parameter}
 Parameter:=AShell.ParameterIndex(0,AParameters);
 
 {Get Delay}
 Delay:=StrToIntDef(Parameter,1000); {Default to 1 second}
 
 {Shutdown}
 Status:=SystemShutdown(Delay);
 if Status = ERROR_SUCCESS then
  begin
   {Show Success}
   Result:=AShell.DoOutput(ASession,'Shutting down in ' + IntToStr(Delay) + ' milliseconds');
  end
 else
  begin
   {Show Failure}
   Result:=AShell.DoOutput(ASession,'Shutdown request failed (Error=' + ErrorToString(Status) + ')');
  end;  
end;

{==============================================================================}
{==============================================================================}
{TShellCommandUptime}
constructor TShellCommandUptime.Create;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_UPTIME;
 Flags:=SHELL_COMMAND_FLAG_INFO or SHELL_COMMAND_FLAG_HELP;
end;
 
{==============================================================================}

function TShellCommandUptime.DoHelp(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Help}
 Result:=AShell.DoOutput(ASession,'Show system uptime since last restart');
end;

{==============================================================================}

function TShellCommandUptime.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'Show system uptime since last restart');
end;

{==============================================================================}

function TShellCommandUptime.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; 
var
 WorkTime:TDateTime;
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Show Uptime}
 WorkTime:=SystemFileTimeToDateTime(Uptime); {No Conversion}
 Result:=AShell.DoOutput(ASession,'Uptime ' + IntToStr(Trunc(WorkTime)) + ' days ' + TimeToStr(WorkTime));
end;

{==============================================================================}
{==============================================================================}
{TShellCommandThreads}
constructor TShellCommandThreads.Create;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_THREAD;
 Flags:=SHELL_COMMAND_FLAG_INFO or SHELL_COMMAND_FLAG_HELP;
end;
 
{==============================================================================}

function TShellCommandThreads.DoHelp(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Help}
 Result:=AShell.DoOutput(ASession,'List or display information about threads');
end;

{==============================================================================}

function TShellCommandThreads.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'List or display information about threads');
end;

{==============================================================================}

function TShellCommandThreads.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Command}
 //To Do
 Result:= AShell.DoOutput(ASession,'Sorry, not implemented yet');
end;

{==============================================================================}
{==============================================================================}
{TShellCommandMemory}
constructor TShellCommandMemory.Create;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_MEMORY;
 Flags:=SHELL_COMMAND_FLAG_INFO or SHELL_COMMAND_FLAG_HELP;
end;
 
{==============================================================================}

function TShellCommandMemory.DoHelp(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Help}
 Result:=AShell.DoOutput(ASession,'Display summary or detailed information about memory');
end;

{==============================================================================}

function TShellCommandMemory.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'Display summary or detailed information about memory');
end;

{==============================================================================}

function TShellCommandMemory.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Command}
 //To Do
 Result:= AShell.DoOutput(ASession,'Sorry, not implemented yet');
end;
 
{==============================================================================}
{==============================================================================}
{TShellCommandDevices}
constructor TShellCommandDevices.Create;
begin
 {}
 inherited Create;

 Name:=SHELL_COMMAND_DEVICE;
 Flags:=SHELL_COMMAND_FLAG_INFO or SHELL_COMMAND_FLAG_HELP;
end;
 
{==============================================================================}

function TShellCommandDevices.DoHelp(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Help}
 Result:=AShell.DoOutput(ASession,'List or display information about devices');
end;

{==============================================================================}

function TShellCommandDevices.DoInfo(AShell:TShell;ASession:TShellSession):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Info}
 Result:=AShell.DoOutput(ASession,'List or display information about devices');
end;

{==============================================================================}

function TShellCommandDevices.DoCommand(AShell:TShell;ASession:TShellSession;AParameters:TStrings):Boolean; 
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Do Command}
 //To Do
 Result:= AShell.DoOutput(ASession,'Sorry, not implemented yet');
end;
 
{==============================================================================}
{==============================================================================}
{Initialization Functions}
procedure ShellInit;
begin
 {}
 {Check Initialized}
 if ShellInitialized then Exit;
 
 {Initialize Logging}
 SHELL_LOG_ENABLED:=(SHELL_DEFAULT_LOG_LEVEL <> SHELL_LOG_LEVEL_NONE); 
 
 {Create Shell Manager}
 ShellManager:=TShellManager.Create;
 
 {Register Default Commands}
 ShellManager.RegisterCommand(TShellCommandHelp.Create);
 ShellManager.RegisterCommand(TShellCommandInfo.Create);
 ShellManager.RegisterCommand(TShellCommandVer.Create);
 ShellManager.RegisterCommand(TShellCommandTime.Create);
 ShellManager.RegisterCommand(TShellCommandClear.Create);
 ShellManager.RegisterCommand(TShellCommandRestart.Create);
 ShellManager.RegisterCommand(TShellCommandShutdown.Create);
 ShellManager.RegisterCommand(TShellCommandUptime.Create);
 ShellManager.RegisterCommand(TShellCommandThreads.Create);
 ShellManager.RegisterCommand(TShellCommandMemory.Create);
 ShellManager.RegisterCommand(TShellCommandDevices.Create);
 
 ShellInitialized:=True;
end;

{==============================================================================}
{==============================================================================}
{Shell Functions}
function ShellGetShell(APrevious:TShell;ALock,AUnlock:Boolean):TShell;
begin
 {}
 Result:=nil;
 
 {Check Manager}
 if ShellManager = nil then Exit;
 
 {Get Shell}
 Result:=ShellManager.GetShell(APrevious,ALock,AUnlock);
end;

{==============================================================================}


function ShellFindShell(const AName:String):TShell;
begin
 {}
 Result:=nil;
 
 {Check Manager}
 if ShellManager = nil then Exit;
 
 {Find Shell}
 Result:=ShellManager.FindShell(AName);
end;

{==============================================================================}

function ShellRegisterShell(AShell:TShell):Boolean;
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Check Manager}
 if ShellManager = nil then Exit;
 
 {Register Shell}
 Result:=ShellManager.RegisterShell(AShell);
end;

{==============================================================================}

function ShellDeregisterShell(AShell:TShell):Boolean;
begin
 {}
 Result:=False;
 
 {Check Shell}
 if AShell = nil then Exit;
 
 {Check Manager}
 if ShellManager = nil then Exit;
 
 {Deregister Shell}
 Result:=ShellManager.DeregisterShell(AShell);
end;

{==============================================================================}

function ShellGetCommand(APrevious:TShellCommand;ALock,AUnlock:Boolean):TShellCommand;
begin
 {}
 Result:=nil;
 
 {Check Manager}
 if ShellManager = nil then Exit;
 
 {Get Command}
 Result:=ShellManager.GetCommand(APrevious,ALock,AUnlock);
end;

{==============================================================================}

function ShellFindCommand(const AName:String):TShellCommand;
begin
 {}
 Result:=nil;
 
 {Check Manager}
 if ShellManager = nil then Exit;
 
 {Find Command}
 Result:=ShellManager.FindCommand(AName);
end;

{==============================================================================}

function ShellRegisterCommand(ACommand:TShellCommand):Boolean;
begin
 {}
 Result:=False;
 
 {Check Command}
 if ACommand = nil then Exit;
 
 {Check Manager}
 if ShellManager = nil then Exit;
 
 {Register Command}
 Result:=ShellManager.RegisterCommand(ACommand);
end;

{==============================================================================}

function ShellDeregisterCommand(ACommand:TShellCommand):Boolean;
begin
 {}
 Result:=False;
 
 {Check Command}
 if ACommand = nil then Exit;
 
 {Check Manager}
 if ShellManager = nil then Exit;
 
 {Deregister Command}
 Result:=ShellManager.DeregisterCommand(ACommand);
end;

{==============================================================================}
{==============================================================================}
{Shell Helper Functions}
procedure ShellLog(Level:LongWord;const AText:String);
var
 WorkBuffer:String;
begin
 {}
 {Check Level}
 if Level < SHELL_DEFAULT_LOG_LEVEL then Exit;
 
 WorkBuffer:='';
 {Check Level}
 if Level = SHELL_LOG_LEVEL_DEBUG then
  begin
   WorkBuffer:=WorkBuffer + '[DEBUG] ';
  end
 else if Level = SHELL_LOG_LEVEL_ERROR then
  begin
   WorkBuffer:=WorkBuffer + '[ERROR] ';
  end;
 
 {Add Prefix}
 WorkBuffer:=WorkBuffer + 'Shell: ';

 {Output Logging} 
 LoggingOutputEx(LOGGING_FACILITY_SHELL,LogLevelToLoggingSeverity(Level),'Shell',WorkBuffer + AText);
end;

{==============================================================================}

procedure ShellLogInfo(const AText:String);
begin
 {}
 ShellLog(SHELL_LOG_LEVEL_INFO,AText);
end;

{==============================================================================}

procedure ShellLogError(const AText:String);
begin
 {}
 ShellLog(SHELL_LOG_LEVEL_ERROR,AText);
end;

{==============================================================================}

procedure ShellLogDebug(const AText:String);
begin
 {}
 ShellLog(SHELL_LOG_LEVEL_DEBUG,AText);
end;

{==============================================================================}
{==============================================================================}

initialization
 ShellInit;
 
{==============================================================================}
 
finalization
 {Nothing}

{==============================================================================}
{==============================================================================}

end.
