-- King André - Slasher of Noble Flames / 王アンドレ－高潔なる炎の斬撃者 / Roi André - Trancheur des Flammes Nobles
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon procedure
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_FIRE),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_WARRIOR),1,99)
    
    -- Multiple attacks
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetValue(s.attacks)
    c:RegisterEffect(e1)

    -- Restrict attacks if no Equip Cards are face-up
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    e2:SetCondition(s.attackcon)
    c:RegisterEffect(e2)
    
    -- Quick effect to send cards to GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCost(s.tgcost)
    e3:SetTarget(s.tgtarget)
    e3:SetOperation(s.tgoperation)
    c:RegisterEffect(e3)
    
    -- Special Summon from GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCost(s.sscost)
    e4:SetTarget(s.sstarget)
    e4:SetOperation(s.ssoperation)
    c:RegisterEffect(e4)
end

-- Function to determine number of attacks
function s.attacks(e,c)
    return Duel.GetMatchingGroupCount(Card.IsType,c:GetControler(),LOCATION_SZONE,LOCATION_SZONE,nil,TYPE_EQUIP)-1
end

-- Condition to restrict attacks if no Equip Cards are face-up
function s.attackcon(e)
    return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_SZONE,LOCATION_SZONE,nil,TYPE_EQUIP)==0
end

-- Quick effect: Cost to banish up to 3 FIRE monsters from GY
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,3,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
    e:SetLabel(#g)
end

function s.costfilter(c)
    return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end

-- Target function to send cards to GY
function s.tgtarget(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=e:GetLabel()
    return true
end

-- Operation to send selected cards to GY
function s.tgoperation(e,tp,eg,ep,ev,re,r,rp)
    local ct=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

-- Special Summon from GY: Cost to banish FIRE or Warrior monsters, excluding itself
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,3,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,3,3,e:GetHandler())
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.costfilter2(c)
    return c:IsType(TYPE_MONSTER) and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_WARRIOR)) and c:IsAbleToRemoveAsCost()
end

function s.sstarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.ssoperation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
