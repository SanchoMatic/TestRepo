-- ブラックロードの炎撃チャー・レッド (Blacklord Blaze of Char-Red)
local s, id = GetID()

function s.initial_effect(c)
    -- Inflict damage by tributing a "Blacklord" monster
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCost(s.cost)
    e1:SetTarget(s.damtg)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)
    
    -- Can be activated from the hand
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetCondition(s.handcon)
    c:RegisterEffect(e2)

    -- Special Summon a "Blacklord" Synchro Monster from banished or GY and inflict damage
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_DAMAGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id + 1, EFFECT_COUNT_CODE_OATH)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

function s.handcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 837543), e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

function s.costfilter(c)
    return c:IsSetCard(0x2226) and c:IsReleasable()
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_MZONE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local g = Duel.SelectMatchingCard(tp, s.costfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.Release(g, REASON_COST)
    e:SetLabel(g:GetFirst():GetBaseAttack())
end

function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, math.floor(e:GetLabel() / 2))
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Damage(1 - tp, math.floor(e:GetLabel() / 2), REASON_EFFECT)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x2226) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil, e, tp)
    if #g > 0 and Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) then
        Duel.Damage(1 - tp, g:GetFirst():GetLevel() * 100, REASON_EFFECT)
    end
end
