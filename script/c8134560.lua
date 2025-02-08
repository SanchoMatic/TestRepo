-- ブラックロード皇帝ドレッドソール (Blacklord Emperor Dred-Sol)
local s, id = GetID()

function s.initial_effect(c)
    -- Synchro summon
    c:EnableReviveLimit()
    Synchro.AddProcedure(c, aux.FilterBoolFunction(Card.IsType, TYPE_TUNER), 1, 1, aux.FilterBoolFunction(Card.IsSetCard, 0x2226), 1, 1)

    -- Banish 1 "Blacklord" monster from your GY as cost; Special Summon 1 "Blacklord" monster with a different name from your hand or Deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Quick Effect: Banish 1 monster, then inflict damage
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_REMOVE + CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.dmgcon)
    e2:SetTarget(s.dmgtg)
    e2:SetOperation(s.dmgop)
    c:RegisterEffect(e2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.rmfilter(c,code)
    return c:IsSetCard(0x2226) and c:IsAbleToRemoveAsCost() and c:GetCode()~=code
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x2226) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then
        local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x2226)
        return g:GetClassCount(Card.GetCode)>1 
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local rg=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.rmfilter), tp, LOCATION_GRAVE, 0, 1, 1, nil,e:GetHandler():GetCode())
    if #rg>0 and Duel.Remove(rg, POS_FACEUP, REASON_COST)~=0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp)
        if #sg>0 then
            Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end

function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end

function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, re:GetHandler(), 1, 0, 0)
    if re:GetHandler():IsOnField() then
        Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1-tp, re:GetHandler():GetAttack() / 2)
    end
end

function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    local tc=re:GetHandler()
    if Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
        if tc:IsPreviousLocation(LOCATION_ONFIELD) then
            Duel.Damage(1-tp, tc:GetAttack()/2, REASON_EFFECT)
        end
    end
end
