class Robot < ActiveRecord::Base
    include HealthManager 
    include AutoPresentable 

    belongs_to :code_name 

    has_many :robot_weapons
    has_many :weapons, through: :robot_weapons

    has_one :health, as: :machine 

    validates :code_name, presence: true #, message: "Needs to be a registered robot"
    validates :health, presence: true #, message: "Needs to be initialized with a health status"

    accepts_nested_attributes_for :health
    accepts_nested_attributes_for :robot_weapons

    delegate :damage, to: :code_name
    delegate :name, to: :code_name
    delegate :tech, to: :code_name


    def calculate_damage(total_health=1)
        # doesn't need to be the highest one
        max_damage = self.damage
        best_weapon = nil
        robot_weapons.each do |weapon|
            max_damage = weapon.damage if valid_and_heavier_weapon?(max_damage, weapon)
            best_weapon = weapon
        end
        if best_weapon
            # weapon health
            best_weapon.spent_bullet
            
            # Damage
            self.take_damage best_weapon.recoil
            self.save
        end
        max_damage
    end

    def valid_and_heavier_weapon?(max_damage, weapon_instance)
        weapon_instance.can_use? and weapon_instance.stable? and max_damage < weapon_instance.damage
    end

    # pending test - then change it to work with an array instead of a hash
    def get_instance_state_message
        @status ||= 0
        @status %= 4
        {
            "0" => "H", 
            "1" => "O",  
            "2" => "L", 
            "3" => "A"
        }[ ((@status+=1)-1).to_s ]
    end

end
