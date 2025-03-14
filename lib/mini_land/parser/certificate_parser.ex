defmodule MiniLand.Parser.CertificateParser do
  alias MiniLand.Repo
  alias MiniLand.Schema.Promotion

  def parse_certificate(certificate) do
    promotion = Repo.get!(Promotion, certificate.promotion_id)

    %{
      id: certificate.id,
      buyer_full_name: certificate.buyer_full_name,
      buyer_phone: certificate.buyer_phone,
      receiver_full_name: certificate.receiver_full_name,
      receiver_phone: certificate.receiver_phone,
      cost: certificate.cost,
      valid_until: nil,
      promotion_name: promotion.name
    }
  end

  def valid_until(certificate) do
    certificate.created_at + 30 * 24 * 60 * 60 * 1000
  end
end
