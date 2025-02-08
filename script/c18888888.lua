-- Star Wills Dragon
function c18888888.initial_effect(c)
    -- Change name
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetValue(21159309) -- "Majestic Dragon"'s ID
    c:RegisterEffect(e1)
    
    -- Special Summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,18888888) -- Unique ID for the effect
    e2:SetCondition(c18888888.spcon)
    c:RegisterEffect(e2)
    
    -- Add Spell/Trap
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(44508094,0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,18888889) -- Unique ID for effect copied from Stardust Synchron
    e3:SetCost(c18888888.cmbanGGYcost)
    e3:SetTarget(c18888888.syncstarget)
    e3:SetOperation(c18888888.synchop)
    c:RegisterEffect(e3)
end

function c18888888.cfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON)
end

function c18888888.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c18888888.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end

-- Adjusted GY Banish Cost
function c18888888.cmbanGGYcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-- Applying specific Card Criteria for Stardust Dragon
function c18888888.filter(c)
    return c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:ListsCode(44508094) -- Only cards listing "Stardust Dragon"
end

function c18888888.syncstarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(c18888888.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function c18888888.synchop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,c18888888.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end