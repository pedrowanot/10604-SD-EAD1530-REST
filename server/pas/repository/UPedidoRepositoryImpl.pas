unit UPedidoRepositoryImpl;

interface

uses
  UPedidoRepositoryIntf, UPizzaTamanhoEnum, UPizzaSaborEnum, UDBConnectionIntf, FireDAC.Comp.Client;

type
  TPedidoRepository = class(TInterfacedObject, IPedidoRepository)
  private
    FDBConnection: IDBConnection;
    FFDQuery: TFDQuery;
  public
    constructor Create; reintroduce;
    destructor  Destroy; override;

    procedure efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
      const ATempoPreparo: Integer; const ACodigoCliente: Integer);
    procedure consultarPedido(const ADocumentoCliente: string; out ADadosPedido: TDadosPedido);
  end;

implementation

uses
  UDBConnectionImpl, System.SysUtils, Data.DB, FireDAC.Stan.Param;

const
  CMD_INSERT_PEDIDO
    : String =
    'INSERT INTO tb_pedido (cd_cliente, dt_pedido, dt_entrega, vl_pedido, nr_tempopedido, tx_pizzatamanho, tx_pizzasabor) VALUES (:pCodigoCliente, :pDataPedido, :pDataEntrega, :pValorPedido, :pTempoPedido, :pPizzaTamanho, :pPizzaSabor)';
  CM_CONSULTAR_PEDIDO
    : String =
    'SELECT ped.tx_pizzatamanho, '+
    '       ped.tx_pizzasabor, '+
    '       ped.vl_pedido, ' +
    '       ped.nr_tempopedido, '+
    '       ped.cd_cliente '+
    ' FROM tb_cliente cli '+
    ' INNER JOIN tb_pedido ped '+
    '    ON (ped.cd_cliente = cli.id) '+
    ' WHERE (cli.nr_documento = :pDocumentoCliente)'+
    ' ORDER BY ped.id DESC '+
    ' LIMIT 1 ';

  { TPedidoRepository }

procedure TPedidoRepository.consultarPedido(const ADocumentoCliente: string;
  out ADadosPedido: TDadosPedido);
begin
  FFDQuery.SQL.Clear;
  FFDQuery.SQL.Text := CM_CONSULTAR_PEDIDO;
  FFDQuery.ParamByName('pDocumentoCliente').AsString := ADocumentoCliente;
  FFDQuery.Prepare;
  try
    FFDQuery.Open;
    if not FFDQuery.IsEmpty then
    begin
      ADadosPedido.PedidoDocumentoCliente := ADocumentoCliente;
      ADadosPedido.PedidoValor            := FFDQuery.FieldByName('vl_pedido').AsCurrency;
      ADadosPedido.PedidoTempoPreparo     := FFDQuery.FieldByName('nr_tempopedido').AsInteger;
      ADadosPedido.PedidoCodigoCliente    := FFDQuery.FieldByName('cd_cliente').AsInteger;
      ADadosPedido.PizzaSabor             := TPizzaSaborEnum(FFDQuery.FieldByName('tx_pizzasabor').AsInteger);
      ADadosPedido.PizzaTamanho           := TPizzaTamanhoEnum(FFDQuery.FieldByName('tx_pizzatamanho').AsInteger);
    end;
    while not FFDQuery.Eof do
    begin
      ADadosPedido.PedidoDocumentoCliente := ADocumentoCliente;
      FFDQuery.Next;
    end;

  finally
    FFDQuery.Close;
  end;
end;

constructor TPedidoRepository.Create;
begin
  inherited;

  FDBConnection := TDBConnection.Create;
  FFDQuery := TFDQuery.Create(nil);
  FFDQuery.Connection := FDBConnection.getDefaultConnection;
end;

destructor TPedidoRepository.Destroy;
begin
  FFDQuery.Free;
  inherited;
end;

procedure TPedidoRepository.efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
  const ATempoPreparo: Integer; const ACodigoCliente: Integer);
begin
  FFDQuery.SQL.Clear;
  FFDQuery.SQL.Text := CMD_INSERT_PEDIDO;

  FFDQuery.ParamByName('pCodigoCliente').AsInteger := ACodigoCliente;
  FFDQuery.ParamByName('pDataPedido').AsDateTime   := now();
  FFDQuery.ParamByName('pDataEntrega').AsDateTime  := now();
  FFDQuery.ParamByName('pValorPedido').AsCurrency  := AValorPedido;
  FFDQuery.ParamByName('pTempoPedido').AsInteger   := ATempoPreparo;
  FFDQuery.ParamByName('pPizzaSabor').AsInteger    := Integer(APizzaSabor);
  FFDQuery.ParamByName('pPizzaTamanho').AsInteger  := Integer(APizzaTamanho);

  FFDQuery.Prepare;
  FFDQuery.ExecSQL(True);
end;

end.
