local s,id=GetID()
function s.initial_effect(c)
    print("Initializing Star Wills Dragon")
    
    -- This card's name becomes "Majestic Dragon" while on the field or in the GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(CARD_MAJESTIC_DRAGON)
    c:RegisterEffect(e1)
    
    -- Special Summon from hand if Level 8 or higher Dragon Synchro monster is on the field (Red Nova Effect)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(s.spcon)
    c:RegisterEffect(e2)
    
    -- Banish from GY to add Spell/Trap that mentions "Stardust Dragon"
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

function s.cfilter(c)
    print("Filtering for Level 8 or higher Dragon Synchro")
    return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    print("Special summon condition checked")
    print("Duel.GetLocationCount(tp,LOCATION_MZONE): ", Duel.GetLocationCount(tp,LOCATION_MZONE))
    print("Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil): ", Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil))
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

function s.thfilter(c)
    print("Filtering for Stardust Dragon related card")
    return c:IsAbleToHand() and (c:IsSetCard(CARD_STARDUST_DRAGON) or (c:IsSetCard(CARD_STARDUST_DRAGON) and c:IsType(TYPE_SPELL+TYPE_TRAP)))
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        print("Checking to banish from GY")
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) 
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
