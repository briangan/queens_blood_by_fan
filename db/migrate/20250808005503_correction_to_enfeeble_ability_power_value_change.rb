class CorrectionToEnfeebleAbilityPowerValueChange < ActiveRecord::Migration[7.2]
  def change
    GameBoardTileAbility.joins(:card_ability).where("type='EnfeebleAbility' and power_value_change > 0").update_all("power_value_change=-1*power_value_change")
  end
end
