unit UPizzariaControllerImpl;

interface

{$I dmvcframework.inc}

uses MVCFramework,
  MVCFramework.Logger,
  MVCFramework.Commons,
  Web.HTTPApp, UPizzaTamanhoEnum, UPizzaSaborEnum, UEfetuarPedidoDTOImpl;

type

  [MVCDoc('Pizzaria backend')]
  [MVCPath('/')]
  TPizzariaBackendController = class(TMVCController)
  public
    [MVCPath('/')]
    [MVCHTTPMethod([httpGET])]

    [MVCDoc('Criar novo pedido "201: Created"')]
    [MVCPath('/efetuarPedido')]
    [MVCHTTPMethod([httpPOST])]
    procedure efetuarPedido(const AContext: TWebContext);

    [MVCDoc('Consultar ultimo pedido')]
    [MVCPath('/consultarPedido/($doc)')]
    [MVCHTTPMethod([httpGET])]
    procedure consultarPedido();
  end;

implementation

uses
  System.SysUtils,
  Rest.json,
  MVCFramework.SystemJSONUtils,
  UPedidoServiceIntf,
  UPedidoServiceImpl, UPedidoRetornoDTOImpl;

{ TApp1MainController }

procedure TPizzariaBackendController.consultarPedido;
var
  oPedidoServ: TPedidoService;
begin
  oPedidoServ := TPedidoService.Create;
  try
     Render(TJson.ObjectToJsonString(oPedidoServ.consultarPedido(Context.Request.Params['doc'])));
  finally
    oPedidoServ.Free;
  end;
  Log.Info('==>Executou o método ', 'consultarPedido');
end;

procedure TPizzariaBackendController.efetuarPedido(const AContext: TWebContext);
var
  oEfetuarPedidoDTO: TEfetuarPedidoDTO;
  oPedidoRetornoDTO: TPedidoRetornoDTO;
begin
  oEfetuarPedidoDTO := AContext.Request.BodyAs<TEfetuarPedidoDTO>;
  try
    with TPedidoService.Create do
    try
      oPedidoRetornoDTO := efetuarPedido(oEfetuarPedidoDTO.PizzaTamanho, oEfetuarPedidoDTO.PizzaSabor, oEfetuarPedidoDTO.DocumentoCliente);
      Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
    finally
      oPedidoRetornoDTO.Free
    end;
  finally
    oEfetuarPedidoDTO.Free;
  end;
  Log.Info('==>Executou o método ', 'efetuarPedido');
end;

end.
