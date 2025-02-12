-- Price of War / 戦争の代償 / Le Prix de la Guerre
local s,id=GetID()
function s.initial_effect(c)
    -- Activate from hand if opponent controls more face-up cards
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetCondition(s.handcon)
    c:RegisterEffect(e1)

    -- Destroy and banish
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_HAND+LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.condition)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

function s.handcon(e)
    local tp=e:GetHandlerPlayer()
    return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsControler,tp,0,LOCATION_MZONE,1,nil,1-tp) end
    if e:GetHandler():IsLocation(LOCATION_HAND) then
        -- Prompt to select Spell/Trap zone
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
        local zone=Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,0)
        Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEUP,true,zone)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsControler,tp,0,LOCATION_MZONE,1,1,nil,1-tp)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end
